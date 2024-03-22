class AddLegalRepresentativePositionToOnlineApplicationTable < ActiveRecord::Migration[7.1]
  def change
    add_column :online_applications, :legal_representative_position, :string
  end
end
