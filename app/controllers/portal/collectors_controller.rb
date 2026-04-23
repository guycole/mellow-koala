class Portal::CollectorsController < Portal::BaseController
  def index
    @collectors = Collector.order(:display_name).includes(
      :configuration_snapshots, :collection_snapshots
    )
    @staleness_window = ENV.fetch("STALENESS_WINDOW_HOURS", 24).to_i.hours
  end

  def show
    @collector = Collector.find_by!(slug: params[:slug])
    redirect_to collection_collector_path(@collector) if @collector.collection_only?
    @latest_config = @collector.configuration_snapshots.accepted.recent.first
    @config_history = @collector.configuration_snapshots.accepted.recent.limit(10)
  end

  def collection
    @collector = Collector.find_by!(slug: params[:slug])
    @latest_collection = @collector.collection_snapshots.accepted.recent.first
    @collection_history = @collector.collection_snapshots.accepted.recent.limit(10)
  end
end
