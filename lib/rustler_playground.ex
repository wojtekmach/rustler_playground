defmodule RustlerPlayground do
  defmacro __using__(options) do
    Module.put_attribute(__CALLER__.module, :rustler_playground_options, options)

    quote do
      import RustlerPlayground, only: [sigil_RUST: 2]
    end
  end

  defmacro sigil_RUST({:<<>>, _, [binary]}, []) do
    options = Module.get_attribute(__CALLER__.module, :rustler_playground_options)
    {quiet, options} = Keyword.pop(options, :quiet)
    {stderr_to_stdout, options} = Keyword.pop(options, :stderr_to_stdout)

    {cargo_dependencies, options} =
      Keyword.pop(options, :cargo_dependencies, """
      rustler = "#{Application.spec(:rustler, :vsn)}"
      """)

    native_dir = Path.expand("native/rustler_playground_nif")
    File.mkdir_p!(native_dir)

    File.mkdir_p!("#{native_dir}/.cargo")

    File.write!("#{native_dir}/.cargo/config.toml", """
    [target.'cfg(target_os = "macos")']
    rustflags = [
        "-C", "link-arg=-undefined",
        "-C", "link-arg=dynamic_lookup",
    ]
    """)

    File.write!("#{native_dir}/Cargo.toml", """
    [package]
    name = "rustler_playground_nif"
    version = "0.1.0"
    authors = []
    edition = "2021"

    [lib]
    name = "rustler_playground_nif"
    path = "src/lib.rs"
    crate-type = ["cdylib"]

    [dependencies]
    #{cargo_dependencies}
    """)

    File.mkdir_p!("#{native_dir}/src")
    File.write!("#{native_dir}/src/lib.rs", binary)

    into =
      if quiet do
        ""
      else
        IO.stream()
      end

    {_, 0} =
      System.cmd(
        "cargo",
        [
          "rustc"
        ],
        env: %{
          "CARGO_TARGET_DIR" => Application.app_dir(:rustler_playground)
        },
        into: into,
        stderr_to_stdout: stderr_to_stdout,
        cd: native_dir
      )

    File.cp!(
      Application.app_dir(:rustler_playground, "debug/librustler_playground_nif.dylib"),
      Application.app_dir(:rustler_playground, "debug/librustler_playground_nif.so")
    )

    quote do
      use Rustler,
          [
            otp_app: :rustler_playground,
            crate: :rustler_playground_nif,
            skip_compilation?: true,
            load_from: {:rustler_playground, "debug/librustler_playground_nif"}
          ] ++ unquote(options)

      import RustlerPlayground, only: [sigil_RUST: 2]
    end
  end
end
