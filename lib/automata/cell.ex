alias Cizen.Effects.{Dispatch, Receive, Subscribe}
alias Cizen.{Event, Filter}
alias Cells.{Tick, Update, Energy}

defmodule Cells.Automata.Cell do
  use Cizen.Automaton

  defstruct [:x, :y, :value]

  @impl true
  def spawn(id, %{x: x, y: y, value: value}) do
    perform id, %Subscribe{
      event_filter: Filter.new(fn %Event{body: %Tick{}} -> true end)
    }

    perform id, %Subscribe{
      # TODO: Use 'event_body_filters' to get events targeted to me
      event_filter: Filter.new(fn %Event{body: %Energy{}} -> true end)
    }

    # Initial updating
    perform id, %Dispatch{
      body: %Update{x: x, y: y, value: value}
    }

    {x, y, value}
  end

  @impl true
  def yield(id, {x, y, value}) do
    event = perform id, %Receive{}
    case event.body do
      %Energy{x: ex, y: ey, diff: diff} when x == ex and y == ey ->
        {x, y, value + diff}
      %Tick{} ->
        if value > 0 do
          # Diffusion
          outflow = value * 0.2
          Enum.each -1..1, fn dx ->
            Enum.each -1..1, fn dy ->
              if dx != 0 and dy != 0 do
                k = cond do
                  dx == 0 or dy == 0 -> 0.2
                  true -> 0.05
                end
                perform id, %Dispatch{
                  body: %Energy{x: x + dx, y: y + dy, diff: k * outflow}
                }
              end
            end
          end

          new_value = value - outflow
          new_value = if new_value < 0.001 do 0 else new_value end

          # Update
          perform id, %Dispatch{
            body: %Update{x: x, y: y, value: new_value}
          }
          {x, y, new_value}
        else
          {x, y, 0}
        end
      _ -> {x, y, value}
    end
  end
end
