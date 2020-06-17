class AddBenefitsOverrideToOnlineApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :online_applications, :benefits_override, :boolean, default: false
  end
end
