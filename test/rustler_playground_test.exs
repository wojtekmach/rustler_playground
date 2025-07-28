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

defmodule RustlerPlaygroundTest do
  use ExUnit.Case, async: true

  test "add/2" do
    assert DemoNIF.add(1, 2) == 3
  end
end
