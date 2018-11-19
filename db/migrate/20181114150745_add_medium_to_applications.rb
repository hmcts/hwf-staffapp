class AddMediumToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :medium, :string

    reversible do |direction|
      direction.up do
        Application.where("reference ~* ?", "HWF").update_all(medium: "digital")
        Application.where.not("reference ~* ?", "HWF").update_all(medium: "paper")
      end
    end
  end
end
