defmodule LegalDoc.DocumentsTest do
  use LegalDoc.DataCase

  alias LegalDoc.Documents

  describe "documents" do
    alias LegalDoc.Documents.Document

    import LegalDoc.DocumentsFixtures

    @invalid_attrs %{status: nil, title: nil, summary: nil, file_path: nil}

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      assert Documents.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      valid_attrs = %{status: "some status", title: "some title", summary: "some summary", file_path: "some file_path"}

      assert {:ok, %Document{} = document} = Documents.create_document(valid_attrs)
      assert document.status == "some status"
      assert document.title == "some title"
      assert document.summary == "some summary"
      assert document.file_path == "some file_path"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{status: "some updated status", title: "some updated title", summary: "some updated summary", file_path: "some updated file_path"}

      assert {:ok, %Document{} = document} = Documents.update_document(document, update_attrs)
      assert document.status == "some updated status"
      assert document.title == "some updated title"
      assert document.summary == "some updated summary"
      assert document.file_path == "some updated file_path"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_document(document, @invalid_attrs)
      assert document == Documents.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end
end
