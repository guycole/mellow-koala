class TasksController < ApplicationController
  allow_unauthenticated_access only: [:index]

  def index
    scope = Task.all

    if params[:name].present?
      scope = scope.where("name LIKE ?", "%#{params[:name]}%")
    end
    if params[:host].present?
      scope = scope.where("host LIKE ?", "%#{params[:host]}%")
    end

    sort_column = %w[name host start_time stop_time].include?(params[:sort]) ? params[:sort] : "start_time"
    sort_direction = params[:direction] == "asc" ? :asc : :desc
    scope = scope.order(Arel.sql("#{Task.connection.quote_column_name(sort_column)} #{sort_direction}"))

    @pagy, @tasks = pagy(scope)
  end
end
