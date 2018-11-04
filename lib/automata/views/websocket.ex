alias Cizen.Effects.{Start, Dispatch, Receive, Subscribe}
alias Cizen.{Event, Filter}
alias Cells.Events.{Tick, Update, Energy}

defmodule Cells.Point do
  defstruct [:x, :y]
end

defmodule Cells.Automata.Views.WebSocketInput do
  use Cizen.Automaton

  defstruct [:client]

  @impl true
  def spawn(_, %{client: client}) do
    {client}
  end

  @impl true
  def yield(id, {client}) do
    { :text, raw } = client |> Socket.Web.recv!
    %Cells.Point{:x => x, :y => y} = Poison.decode!(raw, as: %Cells.Point{})
    perform id, %Dispatch{
      body: %Energy{x: x, y: y, diff: 50.0}
    }
    {client}
  end
end

defmodule Cells.Automata.Views.WebSocket do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    perform id, %Subscribe{
      event_filter: Filter.new(fn %Event{body: %Tick{}} -> true end)
    }
    perform id, %Subscribe{
      event_filter: Filter.new(fn %Event{body: %Update{}} -> true end)
    }

    server = Socket.Web.listen! 8080
    client = server |> Socket.Web.accept!
    client |> Socket.Web.accept!

    perform id, %Start{
      saga: %Cells.Automata.Views.WebSocketInput{client: client}
    }

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
            Matrix.set(acc, y, x, value)
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
