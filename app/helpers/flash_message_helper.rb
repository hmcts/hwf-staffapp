module FlashMessageHelper
  def format_managers_contacts(managers)
    if managers.empty?
      'a manager'
    else
      managers.map do |m|
        "<a href=\"mailto:#{m.email}\">#{m.name}</a>"
      end.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
    end
  end

  def format_managers_combined_contacts(managers, start_sentence = false)
    if managers.empty?
      start_sentence ? 'A manager' : 'a manager'
    else
      link_text = 'managers'
      link_text = link_text.capitalize! if start_sentence
      "<a href='mailto:#{managers.map(&:email).join(';')}'>#{link_text}</a>"
    end
  end

  def devise_reset_token_error?
    resource && resource.errors.messages.key?(:reset_password_token)
  end
end
