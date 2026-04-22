class Component < ApplicationRecord
  has_many :configuration_snapshots, dependent: :destroy
  has_many :collection_snapshots, dependent: :destroy

  has_secure_password :ingest_token, validations: false

  validates :component_id, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :ingest_token_digest, presence: true
  validates :collector, inclusion: { in: [ true, false ] }

  scope :collectors, -> { where(collector: true) }
  scope :non_collectors, -> { where(collector: false) }

  before_validation :set_slug, if: -> { slug.blank? && display_name.present? }

  def self.authenticate_by_token(component_id_param, raw_token)
    component = find_by(component_id: component_id_param)
    return nil unless component
    component.authenticate_ingest_token(raw_token) ? component : nil
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
    last = last_configuration_at
    last.nil? || last < window.ago
  end

  private

  def set_slug
    self.slug = display_name.parameterize
  end
end
