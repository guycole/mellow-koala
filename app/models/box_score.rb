class BoxScore < ApplicationRecord
  validates :uuid, presence: true, uniqueness: true
  validates :task_name, presence: true
  validates :task_uuid, presence: true
  validates :time_stamp, presence: true
  validates :population, numericality: { greater_than_or_equal_to: 0 }
end
