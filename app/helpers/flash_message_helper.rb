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
end
