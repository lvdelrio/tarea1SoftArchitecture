require "test_helper"

class TopSellingBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get top_selling_books_index_url
    assert_response :success
  end
end
