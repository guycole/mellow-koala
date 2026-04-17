class Task < ApplicationRecord
  validates :uuid, presence: true, uniqueness: true
  validates :name, presence: true
  validates :host, presence: true
  validates :start_time, presence: true

  def duration
    return nil if stop_time.nil?
    (stop_time - start_time).to_f
  end

  def duration_display
    return "In Progress" if stop_time.nil?
    total = duration.to_i
    hours = total / 3600
    minutes = (total % 3600) / 60
    seconds = total % 60
    format("%02d:%02d:%02d", hours, minutes, seconds)
  end
end
