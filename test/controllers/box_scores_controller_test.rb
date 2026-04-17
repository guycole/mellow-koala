require "test_helper"

class BoxScoresControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible without login" do
    get box_scores_url
    assert_response :success
  end

  test "index returns box scores" do
    BoxScore.create!(uuid: SecureRandom.uuid, task_name: "t1", task_uuid: SecureRandom.uuid, population: 10, time_stamp: Time.current)
    get box_scores_url
    assert_response :success
  end
end
