class GuideController < ApplicationController
  before_action :authenticate_user!

  respond_to :md

  def index
  end
end
