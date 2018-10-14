alias Cizen.Effects.{Receive, Subscribe}
alias Cizen.EventFilter
alias Cells.Update

defmodule Cells.Automata.Renderers.Console do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Update)
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
