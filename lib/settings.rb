module Settings

module_function

  file_path = File.expand_path('../config/settings.yml', __dir__)
  @h        = YAML.load_file(file_path)

  def mail_from
    @h['mail_from']
  end

  def mail_reply_to
    @h['mail_reply_to']
  end

  def mail_tech_support
    @h['mail_tech_support']
  end

  def mail_feedback
    @h['mail_feedback']
  end
end
