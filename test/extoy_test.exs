defmodule ExtoyTest do
  use ExUnit.Case
  doctest Extoy

  test "greets the world" do
    assert Extoy.hello() == :world
  end
end
