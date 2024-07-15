class ChangePartnerOver61NameInApplications < ActiveRecord::Migration[7.1]
  def change
    rename_column :applications, :partner_over_61, :partner_over_66
  end
end
