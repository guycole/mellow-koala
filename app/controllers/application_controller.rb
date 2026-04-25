class ApplicationController < ActionController::Base
  # Expose nav_collectors for the sidebar
  helper_method :nav_collectors

  private

  def nav_collectors
    @nav_collectors ||= ::Collector.order(:display_name)
  end
end
