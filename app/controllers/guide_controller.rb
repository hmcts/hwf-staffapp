class GuideController < ApplicationController
  skip_after_action :verify_authorized
  skip_before_action :authenticate_user!

  respond_to :md

  def index; end

  def accessibility_statement; end
end
