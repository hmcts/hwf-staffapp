class ChangeProbateToAcceptNull < ActiveRecord::Migration
  def change
    change_column_null :online_applications, :probate, true
  end
end
