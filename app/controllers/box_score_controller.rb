class BoxScoreController < ApplicationController
  def index
    @box_scores = BoxScore.all
  end

  def show
    @box_score = BoxScore.find(params[:id])
  end

  def new
    @box_score = BoxScore.new
  end

  def create
    @box_score = BoxScore.new(box_score_params)
    if @box_score.save
      redirect_to @box_score
    else
      render :new
    end
  end

  def edit
    @box_score = BoxScore.find(params[:id])
  end

  def update
    @box_score = BoxScore.find(params[:id])
    if @box_score.update(box_score_params)
      redirect_to @box_score
    else
      render :edit
    end
  end

  def destroy
    @box_score = BoxScore.find(params[:id])
    @box_score.destroy
    redirect_to box_score_index_path
  end

  private

  def box_score_params
    params.require(:box_score).permit(:task_name, :task_uuid, :population, :time_stamp)
  end
end
