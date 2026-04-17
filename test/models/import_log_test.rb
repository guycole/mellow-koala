require "test_helper"

class ImportLogTest < ActiveSupport::TestCase
  def valid_attrs
    {
      source_file: "data/tasks.json",
      import_type: "tasks",
      run_at: Time.current,
      records_processed: 10,
      records_inserted: 8,
      records_skipped: 2
    }
  end

  test "valid import log saves" do
    assert ImportLog.new(valid_attrs).valid?
  end

  test "source_file presence required" do
    assert_not ImportLog.new(valid_attrs.merge(source_file: nil)).valid?
  end

  test "import_type presence required" do
    assert_not ImportLog.new(valid_attrs.merge(import_type: nil)).valid?
  end

  test "run_at presence required" do
    assert_not ImportLog.new(valid_attrs.merge(run_at: nil)).valid?
  end

  test "import_type must be tasks or box_scores" do
    assert ImportLog.new(valid_attrs.merge(import_type: "box_scores")).valid?
    assert_not ImportLog.new(valid_attrs.merge(import_type: "invalid")).valid?
  end

  test "records_processed must be >= 0" do
    assert_not ImportLog.new(valid_attrs.merge(records_processed: -1)).valid?
  end

  test "records_inserted must be >= 0" do
    assert_not ImportLog.new(valid_attrs.merge(records_inserted: -1)).valid?
  end

  test "records_skipped must be >= 0" do
    assert_not ImportLog.new(valid_attrs.merge(records_skipped: -1)).valid?
  end
end
