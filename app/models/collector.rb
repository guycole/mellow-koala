class Collector < ApplicationRecord
  has_many :configuration_snapshots, dependent: :destroy
  has_many :collection_snapshots, dependent: :destroy

  has_secure_password :ingest_token, validations: false

  validates :collector_id, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :ingest_token_digest, presence: true
  validates :collection_only, inclusion: { in: [ true, false ] }

  scope :collection_only_collectors, -> { where(collection_only: true) }
  scope :non_collection_only, -> { where(collection_only: false) }

  before_validation :set_slug, if: -> { slug.blank? && display_name.present? }

  def self.authenticate_by_token(collector_id_param, raw_token)
    collector = find_by(collector_id: collector_id_param)
    return nil unless collector
    collector.authenticate_ingest_token(raw_token) ? collector : nil
  end

  def to_param
    slug
  end

  def last_configuration_at
    configuration_snapshots.where(status: "accepted").order(received_at: :desc).pick(:received_at)
  end

  def last_collection_at
    collection_snapshots.where(status: "accepted").order(received_at: :desc).pick(:received_at)
  end

  def stale?(window = nil)
    window ||= ENV.fetch("STALENESS_WINDOW_HOURS", 24).to_i.hours
    last = last_collection_at
    last.nil? || last < window.ago
  end

  private

  def set_slug
    self.slug = display_name.parameterize
  end
end
