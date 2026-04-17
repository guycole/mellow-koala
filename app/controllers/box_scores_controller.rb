class BoxScoresController < ApplicationController
  allow_unauthenticated_access only: [:index]

  def index
    scope = BoxScore.all

    if params[:task_name].present?
      scope = scope.where("task_name LIKE ?", "%#{params[:task_name]}%")
    end
    if params[:task_uuid].present?
      scope = scope.where(task_uuid: params[:task_uuid])
    end

    sort_column = %w[task_name task_uuid time_stamp population].include?(params[:sort]) ? params[:sort] : "time_stamp"
    sort_direction = params[:direction] == "asc" ? "asc" : "desc"
    scope = scope.order("#{sort_column} #{sort_direction}")

    @pagy, @box_scores = pagy(scope)
  end
end
