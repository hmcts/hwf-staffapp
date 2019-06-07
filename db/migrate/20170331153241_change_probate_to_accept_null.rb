class ChangeProbateToAcceptNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :online_applications, :probate, true
  end
end
