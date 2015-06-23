class CreateJoinTableOfficeJurisdiction < ActiveRecord::Migration
  def change
    create_join_table :offices, :jurisdictions, table_name: :office_jurisdictions do |t|
      t.index [:office_id, :jurisdiction_id]
    end
    add_foreign_key :office_jurisdictions, :offices
    add_foreign_key :office_jurisdictions, :jurisdictions
  end
end
