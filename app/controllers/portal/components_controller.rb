class Portal::ComponentsController < Portal::BaseController
  def index
    @components = Component.order(:display_name).includes(
      :configuration_snapshots, :collection_snapshots
    )
    @staleness_window = ENV.fetch("STALENESS_WINDOW_HOURS", 24).to_i.hours
  end

  def show
    @component = Component.find_by!(slug: params[:slug])
    redirect_to collection_component_path(@component) if @component.collector?
    @latest_config = @component.configuration_snapshots.accepted.recent.first
    @config_history = @component.configuration_snapshots.accepted.recent.limit(10)
  end

  def collection
    @component = Component.find_by!(slug: params[:slug])
    @latest_collection = @component.collection_snapshots.accepted.recent.first
    @collection_history = @component.collection_snapshots.accepted.recent.limit(10)
  end
end
