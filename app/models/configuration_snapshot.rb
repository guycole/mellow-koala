class ConfigurationSnapshot < ApplicationRecord
  belongs_to :collector

  validates :snapshot_id, presence: true
  validates :received_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[accepted rejected] }
  validates :payload, presence: true
  validates :snapshot_id, uniqueness: { scope: :collector_id }

  before_validation :set_received_at, on: :create

  scope :accepted, -> { where(status: "accepted") }
  scope :recent, -> { order(received_at: :desc) }

  private

  def set_received_at
    self.received_at ||= Time.current
  end
end
