defmodule DerpWeb.ReviewRequestView do
  use DerpWeb, :view
  alias DerpWeb.ReviewRequestView

  def render("index.json", %{review_requests: review_requests}) do
    %{data: render_many(review_requests, ReviewRequestView, "review_request.json")}
  end

  def render("show.json", %{review_request: review_request}) do
    %{data: render_one(review_request, ReviewRequestView, "review_request.json")}
  end

  def render("review_request.json", %{review_request: review_request}) do
    %{
      id: review_request.id,
      address: review_request.address,
      last_request: review_request.last_request
    }
  end
end
