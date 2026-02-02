class Task < ApplicationRecord
  before_create :set_uuid

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end
end
