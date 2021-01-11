class AddNewJurisdiction < ActiveRecord::Migration[6.0]
  def up
    Jurisdiction.create(name: 'UT Lands Chamber')
  end

  def down
    Jurisdiction.find_by(name: 'UT Lands Chamber').destroy
  end
end
