class FeedbackController < ApplicationController
  respond_to :html

  def index
    authorize :feedback

    @feedback = Feedback.order(created_at: :desc)
  end

  def new
    @feedback = Feedback.new
    authorize @feedback

    respond_with(@feedback)
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user
    @feedback.office = current_user.office

    authorize @feedback

    if @feedback.save
      flash[:notice] = 'Your feedback has been recorded'
      redirect_to root_path
    else
      respond_with(@feedback)
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:experience, :ideas, :rating, :help)
  end
end
