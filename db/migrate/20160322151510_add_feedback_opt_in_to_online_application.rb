class AddFeedbackOptInToOnlineApplication < ActiveRecord::Migration
  def change
    add_column :online_applications, :feedback_opt_in, :boolean, null: false
  end
end
