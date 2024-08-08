require "test_helper"

class TopRatedBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get top_rated_books_index_url
    assert_response :success
  end
end
