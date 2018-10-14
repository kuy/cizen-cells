alias Cizen.Effects.{Dispatch, Receive, Start, Monitor}
alias Cells.Energy

defmodule Main do
  use Cizen.Effectful

  def main do
    handle fn id ->
      clock_saga_id = perform id, %Start{
        saga: %Cells.Automata.Clock{}
      }

      perform id, %Start{
        saga: %Cells.Automata.Renderers.WebSocket{}
      }

      #perform id, %Start{
      #  saga: %Cells.Automata.Renderers.Console{}
      #}

      Enum.each range(5), fn x ->
        Enum.each range(5), fn y ->
          perform id, %Start{
            saga: %Cells.Automata.Cell{x: x, y: y, value: 0.0}
          }
        end
      end

      perform id, %Dispatch{
        body: %Energy{x: 2, y: 2, diff: 100.0}
      }

      down_filter = perform id, %Monitor{
        saga_id: clock_saga_id
      }

      perform id, %Receive{
        event_filter: down_filter
      }
    end
  end

  def range(n) do
    %Range{first: 0, last: n - 1}
  end
end

Main.main()
