require "test_helper"

class BoxScoreTest < ActiveSupport::TestCase
  def valid_attrs
    {
      uuid: SecureRandom.uuid,
      task_name: "test-task",
      task_uuid: SecureRandom.uuid,
      population: 42.5,
      time_stamp: Time.current
    }
  end

  test "valid box score saves" do
    assert BoxScore.new(valid_attrs).valid?
  end

  test "uuid presence required" do
    assert_not BoxScore.new(valid_attrs.merge(uuid: nil)).valid?
  end

  test "task_name presence required" do
    assert_not BoxScore.new(valid_attrs.merge(task_name: nil)).valid?
  end

  test "task_uuid presence required" do
    assert_not BoxScore.new(valid_attrs.merge(task_uuid: nil)).valid?
  end

  test "time_stamp presence required" do
    assert_not BoxScore.new(valid_attrs.merge(time_stamp: nil)).valid?
  end

  test "uuid uniqueness" do
    uuid = SecureRandom.uuid
    BoxScore.create!(valid_attrs.merge(uuid: uuid))
    assert_not BoxScore.new(valid_attrs.merge(uuid: uuid)).valid?
  end

  test "population must be >= 0" do
    assert_not BoxScore.new(valid_attrs.merge(population: -1)).valid?
  end

  test "decimal precision round trips" do
    bs = BoxScore.create!(valid_attrs.merge(population: 123.4567))
    assert_in_delta 123.4567, bs.reload.population.to_f, 0.0001
  end
end
