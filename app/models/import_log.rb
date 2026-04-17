class ImportLog < ApplicationRecord
  IMPORT_TYPES = %w[tasks box_scores].freeze

  validates :source_file, presence: true
  validates :import_type, presence: true, inclusion: { in: IMPORT_TYPES }
  validates :run_at, presence: true
  validates :records_processed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :records_inserted, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :records_skipped, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
