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

  describe 'markdown' do
    it 'changes markdown to HTML' do
      source = <<-END.strip_heredoc
        para

        * list
        * item
      END
      expect(markdown(source)).to match(
        %r{\A
          <p>\s*para\s*</p>\s*
          <ul>\s*<li>\s*list\s*</li>\s*<li>\s*item\s*</li>\s*</ul>\s*
        \z}x
      )
    end

    it 'strips arbitrary HTML from input' do
      source = "<blink>It's alive!</blink>"
      expect(markdown(source)).not_to match(/<blink/)
    end
  end
end
