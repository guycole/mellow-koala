class Portal::CarouselController < Portal::BaseController
  DEFAULT_DWELL = 30
  MIN_DWELL = 1
  MAX_DWELL = 3600

  def show
    @dwell = clamp_dwell(params[:dwell].to_i.nonzero? || DEFAULT_DWELL)
    components = Component.order(:display_name).to_a

    if components.empty?
      @next_url = carousel_path(dwell: @dwell)
      @component = nil
      render :empty and return
    end

    # Determine which component to show by cycling via index param
    @index = (params[:index].to_i || 0).clamp(0, components.length - 1)
    @component = components[@index]
    @next_index = (@index + 1) % components.length
    @next_url = carousel_path(index: @next_index, dwell: @dwell)

    # Show the component detail as the carousel page
    @latest_config = @component.configuration_snapshots.accepted.recent.first
    @latest_collection = @component.collection_snapshots.accepted.recent.first
  end

  private

  def clamp_dwell(val)
    val.clamp(MIN_DWELL, MAX_DWELL)
  end
end
