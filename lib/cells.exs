alias Cizen.Effects.{Dispatch, Receive, Start, Monitor}
alias Cells.Events.Energy

defmodule Main do
  use Cizen.Effectful

  def main do
    handle fn id ->
      clock_saga_id = perform id, %Start{
        saga: %Cells.Automata.Clock{}
      }

      perform id, %Start{
        saga: %Cells.Automata.Views.WebSocket{}
      }

      #perform id, %Start{
      #  saga: %Cells.Automata.Views.Console{}
      #}

      Enum.each range(5), fn x ->
        Enum.each range(5), fn y ->
          perform id, %Start{
            saga: %Cells.Automata.Cell{x: x, y: y, value: 0.0}
          }
        end
      end

      # Put initial energy
      perform id, %Dispatch{
        body: %Energy{x: 2, y: 2, diff: 150.0}
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
