alias Cizen.Effects.{Receive, Subscribe}
alias Cizen.EventFilter
alias Cells.Render

defmodule Cells.Automata.Renderers.Console do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Render)
    }
    :loop
  end

  @impl true
  def yield(id, :loop) do
    event = perform id, %Receive{}
    %Render{x: x, y: y, value: value} = event.body
    IO.puts "[#{x}, #{y}] value=#{value}"
    :loop
  end
end
