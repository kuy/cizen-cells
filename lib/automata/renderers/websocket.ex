alias Cizen.Effects.{Receive, Subscribe}
alias Cizen.EventFilter
alias Cells.Render

defmodule Cells.Automata.Renderers.WebSocket do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Render)
    }
    server = Socket.Web.listen! 8080
    client = server |> Socket.Web.accept!
    client |> Socket.Web.accept!
    {client}
  end

  @impl true
  def yield(id, {client}) do
    event = perform id, %Receive{}
    client |> Socket.Web.send!({:text, Poison.encode!(event.body)})
    {client}
  end
end
