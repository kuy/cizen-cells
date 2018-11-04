alias Cizen.Effects.{Receive, Subscribe}
alias Cizen.{Event, Filter}
alias Cells.Update

defmodule Cells.Automata.Views.Console do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: Filter.new(fn %Event{body: %Update{}} -> true end)
    }
    :loop
  end

  @impl true
  def yield(id, :loop) do
    event = perform id, %Receive{}
    %Update{x: x, y: y, value: value} = event.body
    IO.puts "[#{x}, #{y}] value=#{value}"
    :loop
  end
end
