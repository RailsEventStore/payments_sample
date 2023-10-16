require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get checkout_url
    assert_response :success
  end
end
