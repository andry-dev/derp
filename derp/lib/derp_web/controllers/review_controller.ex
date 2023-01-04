defmodule DerpWeb.ReviewController do
  use DerpWeb, :controller

  alias Derp.Reviews
  alias Derp.Reviews.Review

  def index(conn, _params) do
    reviews = Reviews.list_reviews()
    render(conn, "index.html", reviews: reviews)
  end

  def new(conn, _params) do
    changeset = Reviews.change_review(%Review{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"review" => review_params}) do
    case Reviews.create_review(review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review created successfully.")
        |> redirect(to: Routes.review_path(conn, :show, review))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    render(conn, "show.html", review: review)
  end

  def edit(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    changeset = Reviews.change_review(review)
    render(conn, "edit.html", review: review, changeset: changeset)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Reviews.get_review!(id)

    case Reviews.update_review(review, review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review updated successfully.")
        |> redirect(to: Routes.review_path(conn, :show, review))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", review: review, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    {:ok, _review} = Reviews.delete_review(review)

    conn
    |> put_flash(:info, "Review deleted successfully.")
    |> redirect(to: Routes.review_path(conn, :index))
  end
end
