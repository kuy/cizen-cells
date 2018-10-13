alias Cizen.Effects.{Dispatch, Receive, Start, Subscribe, Monitor}
alias Cizen.EventFilter

defmodule RequestRender do
  defstruct []
end

defmodule Render do
  defstruct [:x, :y, :value]
end

defmodule Energy do
  defstruct [:x, :y, :diff]
end

defmodule CellAutomaton do
  use Cizen.Automaton

  defstruct [:x, :y, :value]

  @impl true
  def spawn(id, %{x: x, y: y, value: value}) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: RequestRender)
    }
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Energy)
    }
    {x, y, value}
  end

  @impl true
  def yield(id, {x, y, value}) do
    event = perform id, %Receive{}
    case event.body do
      %Energy{x: ex, y: ey, diff: diff} when x == ex and y == ey ->
        new_value = value + diff
        if 0.1 < diff do
          Enum.each Stream.timer(1000), fn _ ->
            outflow = new_value * 0.5
            Enum.each -1..1, fn dx ->
              Enum.each -1..1, fn dy ->
                factor = cond do
                  dx == 0 and dy == 0 -> -1
                  dx == 0 or dy == 0 -> 0.2
                  true -> 0.05
                end
                perform id, %Dispatch{
                  body: %Energy{x: x + dx, y: y + dy, diff: factor * outflow}
                }
              end
            end
          end
        end
        {x, y, new_value}
      %RequestRender{} ->
        perform id, %Dispatch{
          body: %Render{x: x, y: y, value: value}
        }
        {x, y, value}
      _ -> {x, y, value}
    end
  end
end

defmodule ConsoleRendererAutomaton do
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

defmodule WebSocketRendererAutomaton do
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

defmodule Main do
  use Cizen.Effectful

  def main do
    handle fn id ->
      renderer_saga_id = perform id, %Start{
        saga: %WebSocketRendererAutomaton{}
      }

      #perform id, %Start{
      #  saga: %ConsoleRendererAutomaton{}
      #}

      Enum.each 0..4, fn x ->
        Enum.each 0..4, fn y ->
          perform id, %Start{
            saga: %CellAutomaton{x: x, y: y, value: 0.0}
          }
        end
      end

      perform id, %Dispatch{
        body: %RequestRender{}
      }

      perform id, %Dispatch{
        body: %Energy{x: 2, y: 2, diff: 50.0}
      }

      Enum.each Stream.interval(500), fn _ ->
        perform id, %Dispatch{
          body: %RequestRender{}
        }
      end

      down_filter = perform id, %Monitor{
        saga_id: renderer_saga_id
      }

      perform id, %Receive{
        event_filter: down_filter
      }
    end
  end
end

Main.main()
