class Admin::DashboardController < Admin::BaseController
  def index
    @task_count = Task.count
    @box_score_count = BoxScore.count
    @import_log_count = ImportLog.count
    @recent_imports = ImportLog.order(run_at: :desc).limit(5)
  end
end
