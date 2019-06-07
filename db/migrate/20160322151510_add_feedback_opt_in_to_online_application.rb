class AddFeedbackOptInToOnlineApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :feedback_opt_in, :boolean, null: false
  end
end
