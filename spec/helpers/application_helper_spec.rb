require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#hide_login_menu?' do
    it 'false when visiting root path' do
      expect(helper.hide_login_menu?(root_path)).to be false
    end
    it 'true when visiting the sign in path' do
      expect(helper.hide_login_menu?(new_user_session_path)).to be true
    end
    it 'true when visiting the edit password path' do
      expect(helper.hide_login_menu?(edit_user_password_path)).to be true
    end
  end
end
