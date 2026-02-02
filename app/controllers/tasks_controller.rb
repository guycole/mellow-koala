class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    # Show a specific task
  end

  def new
    # Form for a new task
  end

  def create
    # Create a new task
  end

  def edit
    # Edit a task
  end

  def update
    # Update a task
  end

  def destroy
    # Delete a task
  end
end
