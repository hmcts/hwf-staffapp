class GuideController < ApplicationController
  respond_to :md
  def index
    redirect_to user_session_path unless current_user.present?
  end
end
