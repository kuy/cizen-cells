alias Cizen.Effects.Dispatch
alias Cells.Events.Tick

defmodule Cells.Automata.Clock do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(_, _) do
    :loop
  end

  @impl true
  def yield(id, :loop) do
    Process.sleep(500)
    perform id, %Dispatch{
      body: %Tick{}
    }
    :loop
  end
end
