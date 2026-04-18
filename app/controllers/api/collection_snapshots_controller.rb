class Api::CollectionSnapshotsController < Api::BaseController
  def create
    result = Ingestion::IngestSnapshot.new(
      component: @authenticated_component,
      snapshot_class: CollectionSnapshot,
      params: snapshot_params
    ).call

    if result.success?
      render json: accepted_body(result.snapshot), status: result.status_code
    elsif result.status_code == :unprocessable_entity
      render json: error_body("validation_error", "Payload validation failed",
                              { fields: result.errors }), status: :bad_request
    else
      render json: error_body("bad_request", result.errors.join(", ")), status: :bad_request
    end
  end

  private

  def snapshot_params
    body = JSON.parse(request.body.read) rescue {}
    ActionController::Parameters.new(body).permit(:snapshot_id, :captured_at).merge(
      payload: body["payload"]
    )
  end

  def accepted_body(snapshot)
    {
      status: "accepted",
      component_id: snapshot.component.component_id,
      snapshot_id: snapshot.snapshot_id,
      received_at: snapshot.received_at&.iso8601
    }
  end
end
