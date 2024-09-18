defmodule LegalDoc.DocumentProcessorSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_worker(document_id) do
    DynamicSupervisor.start_child(__MODULE__, {LegalDoc.DocumentProcessor, document_id})
  end
end
