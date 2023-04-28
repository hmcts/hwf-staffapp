class AddApplyingMethodToOnlineApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :online_applications, :applying_method, :string
  end
end
