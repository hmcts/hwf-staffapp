class AddLitigationFriendDetailsToOnlineApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :litigation_friend_details, :text
  end
end
