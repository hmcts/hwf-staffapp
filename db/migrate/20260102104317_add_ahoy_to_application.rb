class AddAhoyToApplication < ActiveRecord::Migration[8.1]
  def change
     add_reference :applications, :ahoy_visit
  end
end
