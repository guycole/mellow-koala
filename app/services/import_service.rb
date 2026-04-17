require "yajl"

class ImportService
  attr_reader :source_file, :import_type, :results

  def initialize(source_file, import_type)
    @source_file = source_file
    @import_type = import_type
    @results = { processed: 0, inserted: 0, skipped: 0, errors: [] }
  end

  def call
    raise ArgumentError, "Unknown import type: #{import_type}" unless ImportLog::IMPORT_TYPES.include?(import_type)
    raise ArgumentError, "File not found: #{source_file}" unless File.exist?(source_file)

    File.open(source_file, "r") do |f|
      parser = Yajl::Parser.new
      parser.parse(f) do |record|
        @results[:processed] += 1
        import_record(record)
      end
    end

    record_import_log
    @results
  rescue => e
    @results[:errors] << e.message
    record_import_log
    raise
  end

  private

  def import_record(record)
    case import_type
    when "tasks"
      import_task(record)
    when "box_scores"
      import_box_score(record)
    end
  end

  def import_task(record)
    uuid = record["uuid"]
    if Task.exists?(uuid: uuid)
      @results[:skipped] += 1
      return
    end

    Task.create!(
      uuid: uuid,
      name: record["name"],
      host: record["host"],
      start_time: record["start_time"],
      stop_time: record["stop_time"]
    )
    @results[:inserted] += 1
  rescue ActiveRecord::RecordInvalid => e
    @results[:skipped] += 1
    @results[:errors] << "Task #{uuid}: #{e.message}"
  end

  def import_box_score(record)
    uuid = record["uuid"]
    if BoxScore.exists?(uuid: uuid)
      @results[:skipped] += 1
      return
    end

    BoxScore.create!(
      uuid: uuid,
      task_name: record["task_name"],
      task_uuid: record["task_uuid"],
      population: record["population"],
      time_stamp: record["time_stamp"]
    )
    @results[:inserted] += 1
  rescue ActiveRecord::RecordInvalid => e
    @results[:skipped] += 1
    @results[:errors] << "BoxScore #{uuid}: #{e.message}"
  end

  def record_import_log
    ImportLog.create!(
      source_file: source_file,
      import_type: import_type,
      run_at: Time.current,
      records_processed: @results[:processed],
      records_inserted: @results[:inserted],
      records_skipped: @results[:skipped],
      error_details: @results[:errors].join("\n").presence
    )
  end
end
