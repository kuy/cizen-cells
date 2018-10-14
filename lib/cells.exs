alias Cizen.Effects.{Dispatch, Receive, Start, Monitor}
alias Cells.{RequestRender, Energy}

defmodule Main do
  use Cizen.Effectful

  def main do
    handle fn id ->
      renderer_saga_id = perform id, %Start{
        saga: %Cells.Automata.Renderers.WebSocket{}
      }

      #perform id, %Start{
      #  saga: %Cells.Automata.Renderers.Console{}
      #}

      Enum.each 0..4, fn x ->
        Enum.each 0..4, fn y ->
          perform id, %Start{
            saga: %Cells.Automata.Cell{x: x, y: y, value: 0.0}
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
