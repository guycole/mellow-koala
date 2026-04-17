namespace :import do
  desc "Import tasks from a JSON file. Usage: rake import:tasks FILE=path/to/file.json"
  task tasks: :environment do
    file = ENV.fetch("FILE") { abort "Usage: rake import:tasks FILE=path/to/file.json" }
    service = ImportService.new(file, "tasks")
    results = service.call
    puts "Import complete: #{results[:processed]} processed, #{results[:inserted]} inserted, #{results[:skipped]} skipped"
    if results[:errors].any?
      puts "Errors:"
      results[:errors].each { |e| puts "  - #{e}" }
    end
  end

  desc "Import box scores from a JSON file. Usage: rake import:box_scores FILE=path/to/file.json"
  task box_scores: :environment do
    file = ENV.fetch("FILE") { abort "Usage: rake import:box_scores FILE=path/to/file.json" }
    service = ImportService.new(file, "box_scores")
    results = service.call
    puts "Import complete: #{results[:processed]} processed, #{results[:inserted]} inserted, #{results[:skipped]} skipped"
    if results[:errors].any?
      puts "Errors:"
      results[:errors].each { |e| puts "  - #{e}" }
    end
  end
end
