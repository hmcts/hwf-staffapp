class StaticController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def not_found
    respond_to do |format|
      format.html { render '404' }
      format.woff { render plain: '' }
      format.woff2 { render plain: '' }
      format.png { render plain: '' }
    end
  end
end
