defmodule LegalDocWeb.DocumentLive.Index do
  use LegalDocWeb, :live_view

  alias LegalDoc.Documents
  alias LegalDoc.Documents.Document

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :documents, Documents.list_documents())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, Documents.get_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, %Document{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document, nil)
    |> assign(:expanded_document_id, nil) # Tambahkan assign ini
  end

  @impl true
  def handle_info({LegalDocWeb.DocumentLive.FormComponent, {:saved, document}}, socket) do
    {:noreply, stream_insert(socket, :documents, document)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Documents.get_document!(id)
    file_path = Path.join([Application.app_dir(:legal_doc, "priv/static"), "assets/documents", document.file_path])

    file_exists = File.exists?(file_path)
    IO.inspect(file_exists, label: "File exists")

    if file_exists do
      deletion_result = File.rm(file_path)
      IO.inspect(deletion_result, label: "File deletion result")
    else
      IO.puts("File not found for deletion: #{file_path}")
    end

    case Documents.delete_document(document) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :documents, document)}

      {:error, reason} ->
        IO.inspect(reason, label: "Document deletion error")
        {:noreply, socket |> put_flash(:error, "Failed to delete document: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("show_more_title", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/documents/#{id}")}
  end

  @impl true
  def handle_event("show_more_summary", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/documents/#{id}")}
  end


  defp truncate_text(text, max_length) when is_binary(text) and is_integer(max_length) do
    if String.length(text) > max_length do
      String.slice(text, 0, max_length) <> "..."
    else
      text
    end
  end


end
