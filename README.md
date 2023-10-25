# Extoy

**TOOLS in Pack**
- Extrace (notice: something is wrong with :dbg when use elixir 1.15)
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `extoy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:extoy, "~> 0.1.0"}
  ]
end

defmodule MyTrace do
  @moduledoc """
  use following command in iex

  require Extrace
  MyTrace.start()

  1. :dbg.tpl(:m, :f, :cx)

  2. :dbg.tpl(m, f, spec)
  ## eg1 => :dbg.tpl(Exmock.Service.User, :get, Extrace.match_spec ["user.info", _p])
  ## eg2 => :dbg.tpl(IMSvr.Service.Dungeon, :handle_call, Extrace.match_spec [{:remove_mem, uid_list}, _from, state])
  """
  use Extrace,
      # optional
      config: %{expire: 3000}
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/extoy>.

