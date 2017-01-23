class GuideController < ApplicationController
  skip_after_action :verify_authorized

  respond_to :md

  def index; end
end
