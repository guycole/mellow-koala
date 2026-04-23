class Api::BaseController < ActionController::API
  before_action :authenticate_collector!

  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def authenticate_collector!
    raw_token = extract_bearer_token
    unless raw_token
      render json: error_body("unauthorized", "Missing Authorization header"), status: :unauthorized
      return
    end

    collector_id = params[:collector_id]
    @authenticated_collector = Collector.authenticate_by_token(collector_id, raw_token)
    unless @authenticated_collector
      render json: error_body("forbidden", "Invalid credentials or collector mismatch"), status: :forbidden
    end
  end

  def extract_bearer_token
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")
    header.delete_prefix("Bearer ").strip.presence
  end

  def render_bad_request(e)
    render json: error_body("bad_request", e.message), status: :bad_request
  end

  def render_not_found(_e)
    render json: error_body("not_found", "Collector not found"), status: :not_found
  end

  def error_body(code, message, details = nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details
    body
  end
end
