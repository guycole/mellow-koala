require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible without login" do
    get tasks_url
    assert_response :success
  end

  test "index returns tasks" do
    Task.create!(uuid: SecureRandom.uuid, name: "t1", host: "h1", start_time: 1.hour.ago)
    get tasks_url
    assert_response :success
  end

  test "index filters by name" do
    Task.create!(uuid: SecureRandom.uuid, name: "alpha", host: "h1", start_time: 1.hour.ago)
    Task.create!(uuid: SecureRandom.uuid, name: "beta", host: "h1", start_time: 1.hour.ago)
    get tasks_url, params: { name: "alpha" }
    assert_response :success
    assert_select "td", text: "alpha"
  end
end
