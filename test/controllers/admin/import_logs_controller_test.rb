require "test_helper"

class Admin::ImportLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "admin@example.com", password: "password123")
  end

  test "index redirects without login" do
    get admin_import_logs_url
    assert_redirected_to new_session_url
  end

  test "index accessible when logged in" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    get admin_import_logs_url
    assert_response :success
  end
end
