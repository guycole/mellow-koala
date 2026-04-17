class Admin::ImportLogsController < Admin::BaseController
  def index
    scope = ImportLog.all

    if params[:import_type].present?
      scope = scope.where(import_type: params[:import_type])
    end

    scope = scope.order(run_at: :desc)
    @pagy, @import_logs = pagy(scope)
  end

  def show
    @import_log = ImportLog.find(params[:id])
  end
end
