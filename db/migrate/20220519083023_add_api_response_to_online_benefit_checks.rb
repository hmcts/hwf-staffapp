class AddApiResponseToOnlineBenefitChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :online_benefit_checks, :api_response, :string
  end
end
