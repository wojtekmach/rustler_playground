Mix.install([
  {:rustler_playground, github: "wojtekmach/rustler_playground"}
])

defmodule DemoNIF do
  use RustlerPlayground

  ~RUST"""
  #[rustler::nif]
  fn add(a: i64, b: i64) -> i64 {
      a + b
  }

  rustler::init!("Elixir.DemoNIF");
  """

  def add(_a, _b) do
    :erlang.nif_error(:nif_not_loaded)
  end
end

defmodule Demo do
  def main do
    dbg(DemoNIF.add(1, 3))
  end
end

Demo.main()
