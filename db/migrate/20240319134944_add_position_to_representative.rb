class AddPositionToRepresentative < ActiveRecord::Migration[7.1]
  def change
    add_column :representatives, :position, :string
  end
end
