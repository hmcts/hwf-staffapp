class FeedbackController < ApplicationController
  before_action :authenticate_user!

  respond_to :html

  def new
    authorize! :create, Feedback

    @feedback = Feedback.new
    respond_with(@feedback)
  end

  def create
    authorize! :create, Feedback

    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user
    @feedback.office = current_user.office
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
