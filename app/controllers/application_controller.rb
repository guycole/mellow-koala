class ApplicationController < ActionController::Base
  # Expose nav_components for the sidebar
  helper_method :nav_components

  private

  def nav_components
    @nav_components ||= Component.order(:display_name)
  end
end
