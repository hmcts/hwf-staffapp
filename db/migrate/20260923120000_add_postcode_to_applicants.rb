class AddPostcodeToApplicants < ActiveRecord::Migration[8.1]
  def change
    add_column :applicants, :postcode, :string
  end
end
