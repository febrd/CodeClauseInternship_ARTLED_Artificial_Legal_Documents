defmodule LegalDoc.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LegalDoc.Documents` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        file_path: "some file_path",
        status: "some status",
        summary: "some summary",
        title: "some title"
      })
      |> LegalDoc.Documents.create_document()

    document
  end
end
