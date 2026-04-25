class Portal::CarouselController < Portal::BaseController
  DEFAULT_DWELL = 30
  MIN_DWELL = 1
  MAX_DWELL = 3600

  def show
    @dwell = clamp_dwell(params[:dwell].to_i.nonzero? || DEFAULT_DWELL)
    collectors = ::Collector.order(:display_name).to_a

    if collectors.empty?
      @next_url = carousel_path(dwell: @dwell)
      @collector = nil
      render :empty and return
    end

    # Determine which collector to show by cycling via index param
    @index = (params[:index].to_i || 0).clamp(0, collectors.length - 1)
    @collector = collectors[@index]
    @next_index = (@index + 1) % collectors.length
    @next_url = carousel_path(index: @next_index, dwell: @dwell)

    # Show the collector detail as the carousel page
    @latest_config = @collector.configuration_snapshots.accepted.recent.first
    @latest_collection = @collector.collection_snapshots.accepted.recent.first
  end

  private

  def clamp_dwell(val)
    val.clamp(MIN_DWELL, MAX_DWELL)
  end
end
