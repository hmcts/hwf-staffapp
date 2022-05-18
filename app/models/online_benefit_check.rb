class OnlineBenefitCheck < ActiveRecord::Base
  belongs_to :online_application

  def outcome
    dwp_result == 'Yes' ? 'full' : 'none'
  end

end
