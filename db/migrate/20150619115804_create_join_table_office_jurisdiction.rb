class CreateJoinTableOfficeJurisdiction < ActiveRecord::Migration
  def change
    create_join_table :offices, :jurisdictions, table_name: :office_jurisdictions do |t|
      t.index [:office_id, :jurisdiction_id]
    end
  end
end
