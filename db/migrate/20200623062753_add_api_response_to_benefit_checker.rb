class AddApiResponseToBenefitChecker < ActiveRecord::Migration[6.0]
  def change
    add_column :benefit_checks, :api_response, :string
  end
end
