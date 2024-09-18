defmodule LegalDoc.DocumentsBatchProcessor do
  alias LegalDoc.Documents

  def start_batch_processing() do
    pending_documents = Documents.list_documents() |> Enum.filter(&(&1.status == "PENDING"))
    Enum.each(pending_documents, fn doc ->
      LegalDoc.DocumentProcessorSupervisor.start_worker(doc.id)
    end)
  end
end
