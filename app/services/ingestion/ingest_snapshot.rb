module Ingestion
  class IngestSnapshot
    Result = Struct.new(:success?, :snapshot, :status_code, :errors, keyword_init: true)

    def initialize(component:, snapshot_class:, params:, replace: false)
      @component = component
      @snapshot_class = snapshot_class
      @params = params
      @replace = replace
    end

    def call
      if @params[:payload].nil?
        return Result.new(success?: false, status_code: :bad_request,
                          errors: [ "payload is required" ])
      end

      snapshot_id = @params[:snapshot_id]
      if snapshot_id.blank?
        return Result.new(success?: false, status_code: :bad_request,
                          errors: [ "snapshot_id is required" ])
      end

      if @replace
        call_with_replace(snapshot_id)
      else
        call_with_append(snapshot_id)
      end
    end

    private

    def call_with_replace(snapshot_id)
      snapshot = nil
      @snapshot_class.transaction do
        @snapshot_class.where(component: @component).delete_all
        snapshot = @snapshot_class.new(
          component: @component,
          snapshot_id: snapshot_id,
          captured_at: @params[:captured_at],
          status: "accepted",
          payload: @params[:payload]
        )
        snapshot.save!
      end
      Result.new(success?: true, snapshot: snapshot, status_code: :created)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, status_code: :unprocessable_entity,
                 errors: e.record.errors.full_messages)
    end

    def call_with_append(snapshot_id)
      existing = @snapshot_class.find_by(component: @component, snapshot_id: snapshot_id)
      return Result.new(success?: true, snapshot: existing, status_code: :ok) if existing

      snapshot = @snapshot_class.new(
        component: @component,
        snapshot_id: snapshot_id,
        captured_at: @params[:captured_at],
        status: "accepted",
        payload: @params[:payload]
      )

      if snapshot.save
        Result.new(success?: true, snapshot: snapshot, status_code: :created)
      else
        Result.new(success?: false, status_code: :unprocessable_entity,
                   errors: snapshot.errors.full_messages)
      end
    end
  end
end
