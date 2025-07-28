# Rustler Playground

## Usage

```elixir
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
```

## License

Copyright (c) 2024 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
