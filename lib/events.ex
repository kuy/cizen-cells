defmodule Cells.Events.Tick do
  defstruct []
end

defmodule Cells.Events.Update do
  defstruct [:x, :y, :value]
end

defmodule Cells.Events.Energy do
  defstruct [:x, :y, :diff]
end
