defmodule LegalDocWeb.DocumentController do
  use LegalDocWeb, :controller

  alias LegalDoc.Documents
  alias LegalDoc.Documents.Document

  def index(conn, _params) do
    documents = Documents.list_documents()
    render(conn, :index, documents: documents)
  end

  def new(conn, _params) do
    changeset = Documents.change_document(%Document{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"document" => %{"file_path" => %Plug.Upload{filename: filename, path: temp_path}}}) do
    IO.inspect(%{"file_path" => %Plug.Upload{filename: filename, path: temp_path}}, label: "Document Params")

    valid_formats = ~w(.pdf .docx .pptx .ppt .doc .csv .xls .xlsx .db)
    ext = Path.extname(filename)

    max_size_in_bytes = 20 * 1024 * 1024
    file_size = File.read!(temp_path) |> byte_size()

    target_dir = Path.join([Application.app_dir(:legal_doc, "priv/static"), "assets/documents"])
    target_path = Path.join(target_dir, filename)

    if Enum.member?(valid_formats, String.downcase(ext)) and file_size <= max_size_in_bytes do
      File.mkdir_p(target_dir)

      if File.exists?(target_path) do
        conn
        |> put_flash(:error, "File #{filename} already exists. Please upload a different file.")
        |> redirect(to: ~p"/documents/new")
      else
        case Documents.create_document(%{file_path: filename}) do
          {:ok, document} ->
            IO.puts("Source file path: #{filename}")
            IO.puts("Target file path: #{target_path}")

            case File.cp(temp_path, target_path) do
              :ok ->
                IO.puts("File copied successfully.")
              {:error, reason} ->
                IO.puts("Error copying the file: #{inspect(reason)}")

                document = Documents.get_document!(document.id)
                {:ok, _document} = Documents.delete_document(document)

                conn
                |> put_flash(:error, "Document revoked because of an error while copying the file. #{inspect(reason)}")
                |> redirect(to: ~p"/documents")
            end

            conn
            |> put_flash(:info, "Document created successfully.")
            |> redirect(to: "/documents/#{document.id}")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset)
        end
      end
    else
      allowed_formats_str = Enum.join(valid_formats, ", ")
      max_size_in_mb = div(max_size_in_bytes, 1024 * 1024)

      conn
      |> put_flash(:error, "Invalid document. Allowed formats: #{allowed_formats_str}. Maximum size: #{max_size_in_mb} MB.")
      |> redirect(to: ~p"/documents")
    end
  end

  def create_old(conn, %{"document" => document_params}) do
    case Documents.create_document(document_params) do
      {:ok, document} ->
        conn
        |> put_flash(:info, "Document created successfully.")
        |> redirect(to: ~p"/documents/#{document}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    render(conn, :show, document: document)
  end

  def edit(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    changeset = Documents.change_document(document)
    render(conn, :edit, document: document, changeset: changeset)
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Documents.get_document!(id)

    case Map.get(document_params, "file_path") do
      %Plug.Upload{filename: filename, path: temp_path} when not is_nil(filename) and filename != "" ->

        valid_formats = ~w(.pdf .docx .pptx .ppt .doc .csv .xls .xlsx .db)
        ext = Path.extname(filename) |> String.downcase()

        max_size_in_bytes = 20 * 1024 * 1024
        file_size = File.stat!(temp_path).size

        if Enum.member?(valid_formats, ext) and file_size <= max_size_in_bytes do

          target_dir = Path.join([Application.app_dir(:legal_doc, "priv/static"), "assets/documents"])
          target_path = Path.join(target_dir, filename)


          if File.exists?(target_path) do

            conn
            |> put_flash(:error, "File #{filename} sudah ada di lokasi. Silakan upload file lain.")
            |> redirect(to: ~p"/documents/#{document.id}")
          else

            File.mkdir_p(target_dir)

            file_path_previos = Path.join([Application.app_dir(:legal_doc, "priv/static"), "assets/documents", document.file_path])
            file_previous_exists = File.exists?(file_path_previos)
            IO.inspect(file_previous_exists, label: "File previous exists")
              if file_previous_exists do

                deletion_result = File.rm(file_path_previos)
                 IO.inspect(deletion_result, label: "File deletion result")
                 else
                 IO.puts("File not found for deletion: #{file_path_previos}")
                 end

            case File.cp(temp_path, target_path) do
              :ok ->

                case Documents.update_document(document,
                  %{file_path: filename, title: "-", summary: "-", sentiment: "-", status: "PENDING"}) do
                  {:ok, updated_document} ->


                    conn
                    |> put_flash(:info, "Document updated successfully.")
                    |> redirect(to: ~p"/documents/#{updated_document.id}")

                  {:error, %Ecto.Changeset{} = changeset} ->
                    render(conn, :edit, document: document, changeset: changeset)
                end

              {:error, reason} ->
                IO.puts("Error copying the file: #{inspect(reason)}")
                conn
                |> put_flash(:error, "Terjadi kesalahan saat menyalin file: #{inspect(reason)}")
                |> redirect(to: ~p"/documents/#{document.id}/edit")
            end
          end
        else

          allowed_formats_str = Enum.join(valid_formats, ", ")
          max_size_in_mb = div(max_size_in_bytes, 1024 * 1024)
          conn
          |> put_flash(:error, "Format file tidak valid. Hanya diizinkan: #{allowed_formats_str}. Ukuran maksimal: #{max_size_in_mb} MB.")
          |> redirect(to: ~p"/documents/#{document.id}/edit")
        end


      _ ->
        conn
        |> put_flash(:info, "Tidak ada file yang diunggah. Hanya mengupdate status.")
        |> redirect(to: ~p"/documents/#{document.id}/edit")
    end
  end


end
