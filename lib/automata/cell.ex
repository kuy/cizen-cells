alias Cizen.Effects.{Dispatch, Receive, Subscribe}
alias Cizen.EventFilter
alias Cells.{RequestRender, Render, Energy}

defmodule Cells.Automata.Cell do
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
