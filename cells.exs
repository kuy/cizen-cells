alias Cizen.Effects.{Dispatch, Receive, Start, Subscribe, Monitor}
alias Cizen.EventFilter

defmodule RequestRender do
  defstruct []
end

defmodule Render do
  defstruct [:x, :y, :state]
end

defmodule Poke do
  defstruct [:x, :y]
end

defmodule CellAutomaton do
  use Cizen.Automaton

  defstruct [:x, :y, :state]

  @impl true
  def spawn(id, %{x: x, y: y, state: state}) do
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: RequestRender)
    }
    perform id, %Subscribe{
      event_filter: EventFilter.new(event_type: Poke)
    }
    {x, y, state}
  end

  @impl true
  def yield(id, {x, y, state}) do
    event = perform id, %Receive{}
    case event.body do
      %Poke{x: ex, y: ey} when x == ex and y == ey ->
        {x, y, 1}
      %RequestRender{} ->
        perform id, %Dispatch{
          body: %Render{x: x, y: y, state: state}
        }
        {x, y, state}
      _ -> {x, y, state}
    end
  end
end

defmodule RendererAutomaton do
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
    %Render{x: x, y: y, state: state} = event.body
    IO.puts "[#{x}, #{y}] state=#{state}"
    :loop
  end
end

defmodule Main do
  use Cizen.Effectful

  def main do
    handle fn id ->
      renderer_saga_id = perform id, %Start{
        saga: %RendererAutomaton{}
      }

      Enum.each 0..2, fn x ->
        Enum.each 0..2, fn y ->
          perform id, %Start{
            saga: %CellAutomaton{x: x, y: y, state: 0}
          }
        end
      end

      perform id, %Dispatch{
        body: %RequestRender{}
      }

      perform id, %Dispatch{
        body: %Poke{x: 1, y: 2}
      }

      perform id, %Dispatch{
        body: %RequestRender{}
      }

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
