alias Cizen.Effects.{Receive, Subscribe}
alias Cizen.EventFilter
alias Cells.{Tick, Update}

defmodule Cells.Automata.Renderers.WebSocket do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Tick)
    }
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Update)
    }

    server = Socket.Web.listen! 8080
    client = server |> Socket.Web.accept!
    client |> Socket.Web.accept!

    {client, %{}}
  end

  @impl true
  def yield(id, {client, state}) do
    event = perform id, %Receive{}
    case event.body do
      %Tick{} ->
        matrix = state
          |> Map.to_list
          |> Enum.reduce(Matrix.new(5, 5), fn {{x, y}, value}, acc ->
            Matrix.set(acc, x, y, value)
          end)
        client
          |> Socket.Web.send!({:text, Poison.encode!(matrix)})
        {client, state}
      %Update{x: x, y: y, value: value} ->
        new_state = Map.put(state, {x, y}, value)
        {client, new_state}
      _ -> {client, state}
    end
  end
end
