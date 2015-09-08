module FlashMessageHelper
  def format_managers_contacts(managers)
    if managers.empty?
      'a manager'
    else
      managers.map do |m|
        "<a href=\"mailto:#{m.email}\">#{m.name}</a>"
      end.join(', ')
    end
  end
end
