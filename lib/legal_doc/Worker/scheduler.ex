defmodule LegalDoc.Scheduler do
  use GenServer

  @interval 2_000 

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    schedule_work()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:work, state) do
    LegalDoc.DocumentsBatchProcessor.start_batch_processing()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end
end
