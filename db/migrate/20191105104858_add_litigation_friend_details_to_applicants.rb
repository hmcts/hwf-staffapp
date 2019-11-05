class AddLitigationFriendDetailsToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :litigation_friend_details, :text
  end
end
