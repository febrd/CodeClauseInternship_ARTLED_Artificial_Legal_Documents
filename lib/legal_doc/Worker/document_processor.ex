defmodule LegalDoc.DocumentProcessor do
  use GenServer

  alias LegalDoc.Documents

  def start_link(document_id) do
    IO.inspect(document_id, label: "Starting worker for document")
    GenServer.start_link(__MODULE__, document_id)
  end

  @impl true
  def init(document_id) do
    IO.inspect(document_id, label: "Initializing worker for document")
    process_document(document_id)
    {:ok, document_id}
  end

  defp process_document(document_id) do
    IO.puts("Processing document with ID: #{document_id}")

    document = Documents.get_document!(document_id)
    IO.inspect(document, label: "Document fetched from database")

    script = case Path.extname(document.file_path) do
      _ -> "v3.py"
    end

    case run_python_script(script, document.file_path) do
      {:ok, %{"title" => title, "summary" => summary, "sentiment" => sentiment}} ->
        IO.puts("Document processed successfully with NLP results")
        IO.inspect(%{title: title, summary: summary, sentiment: sentiment}, label: "NLP Analysis Result")

        case Documents.update_document(document, %{title: title, summary: summary, sentiment: sentiment, status: "PROCESSED"}) do
          {:ok, _updated_document} ->
            IO.puts("Document updated with status: PROCESSED")

          {:error, %Ecto.Changeset{} = changeset} ->
            IO.puts("Error updating document: #{inspect(changeset)}")
        end

      {:error, reason} ->
        IO.puts("Error processing document: #{inspect(reason)}")
        case Documents.update_document(document, %{status: "FAILED"}) do
          {:ok, _updated_document} ->
            IO.puts("Document updated with status: FAILED")

          {:error, %Ecto.Changeset{} = changeset} ->
            IO.puts("Error updating document status to FAILED: #{inspect(changeset)}")
        end
    end
  end

  defp run_python_script(script, file_path) do
    IO.puts("Running #{script} for file: #{file_path}")
    case System.cmd("python3", ["lib/legal_doc/Worker/script/#{script}", file_path]) do
      {output, 0} ->
        IO.puts("NLP script executed successfully")
        IO.inspect(output, label: "NLP Script Output")
        case Regex.run(~r/\{.*\}/s, output) do
          [json_output] ->
            case Jason.decode(json_output) do
              {:ok, decoded} ->
                {:ok, decoded}

              {:error, _} ->
                IO.puts("Error decoding JSON output from script")
                {:error, "Invalid JSON output"}
            end
          _ ->
            IO.puts("No valid JSON found in script output")
            {:error, "No valid JSON output"}
        end

      {error_output, _} ->
        IO.puts("Error running NLP script")
        IO.inspect(error_output, label: "Python Script Error Output")
        {:error, error_output}
    end
  end

end
