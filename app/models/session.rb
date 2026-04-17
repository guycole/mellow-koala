class Session < ApplicationRecord
  TIMEOUT_DURATION = 2.hours

  belongs_to :user

  def expired?
    touched_at < TIMEOUT_DURATION.ago
  end
end
