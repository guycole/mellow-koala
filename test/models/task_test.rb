require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def valid_task_attrs
    {
      uuid: SecureRandom.uuid,
      name: "test-task",
      host: "worker-01",
      start_time: 2.hours.ago,
      stop_time: 1.hour.ago
    }
  end

  test "valid task saves successfully" do
    task = Task.new(valid_task_attrs)
    assert task.valid?
  end

  test "uuid presence required" do
    task = Task.new(valid_task_attrs.merge(uuid: nil))
    assert_not task.valid?
    assert_includes task.errors[:uuid], "can't be blank"
  end

  test "name presence required" do
    task = Task.new(valid_task_attrs.merge(name: nil))
    assert_not task.valid?
  end

  test "host presence required" do
    task = Task.new(valid_task_attrs.merge(host: nil))
    assert_not task.valid?
  end

  test "start_time presence required" do
    task = Task.new(valid_task_attrs.merge(start_time: nil))
    assert_not task.valid?
  end

  test "uuid uniqueness" do
    uuid = SecureRandom.uuid
    Task.create!(valid_task_attrs.merge(uuid: uuid))
    duplicate = Task.new(valid_task_attrs.merge(uuid: uuid))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uuid], "has already been taken"
  end

  test "stop_time can be nil" do
    task = Task.new(valid_task_attrs.merge(stop_time: nil))
    assert task.valid?
  end

  test "duration returns nil when stop_time is nil" do
    task = Task.new(valid_task_attrs.merge(stop_time: nil))
    assert_nil task.duration
  end

  test "duration returns Float seconds when stop_time present" do
    start = Time.current - 3600
    stop = Time.current
    task = Task.new(valid_task_attrs.merge(start_time: start, stop_time: stop))
    assert_in_delta 3600.0, task.duration, 1.0
    assert_instance_of Float, task.duration
  end

  test "duration_display returns In Progress for nil stop_time" do
    task = Task.new(valid_task_attrs.merge(stop_time: nil))
    assert_equal "In Progress", task.duration_display
  end

  test "duration_display returns HH:MM:SS format" do
    task = Task.new(valid_task_attrs.merge(
      start_time: Time.current - (2 * 3600 + 15 * 60 + 30),
      stop_time: Time.current
    ))
    assert_match(/\A\d{2}:\d{2}:\d{2}\z/, task.duration_display)
    assert_equal "02:15:30", task.duration_display
  end
end
