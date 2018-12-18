class AddMediumToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :medium, :string

    reversible do |direction|
      direction.up do
        Application.where("reference ~* ?", "HWF").update_all(medium: "digital")
        Application.where("reference !~* ? OR reference IS NULL", "HWF").update_all(medium: 'paper')
      end
    end
  end
end
