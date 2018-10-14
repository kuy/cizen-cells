defmodule Cells.Tick do
  defstruct []
end

defmodule Cells.Update do
  defstruct [:x, :y, :value]
end

defmodule Cells.Energy do
  defstruct [:x, :y, :diff]
end
