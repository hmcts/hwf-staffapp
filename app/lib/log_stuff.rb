class LogStuff
  NAMESPACE = :log

  def self.use_logstasher?
    LogStasher.enabled?
  end

  def self.get_thread_current(name)
    Thread.current[NAMESPACE] ||= {
      current_fields: {},
      current_tags: Set.new
    }
    Thread.current[NAMESPACE][name].dup
  end

  def self.set_thread_current(name, value)
    Thread.current[NAMESPACE] ||= {
      current_fields: {},
      current_tags: Set.new
    }
    Thread.current[NAMESPACE][name] = value.dup
  end

  def self.log(severity = 'info', *, &block)
    return unless block

    if use_logstasher?
      return unless LogStasher.logger.send("#{severity}?")

      msg = yield
      event = build_event(*, msg)
      LogStasher.logger << "#{event.to_json} \n"
    else
      return unless Rails.logger.send("#{severity}?")
      Rails.logger.send(severity, &block)
    end
  end

  def self.build_event(*args, msg)
    local_fields, local_tags = compile_fields_and_tags(args)

    LogStash::Event.new('@source' => LogStasher.source,
                        '@severity' => severity,
                        'message' => msg,
                        '@tags' => get_thread_current(:current_tags).merge(local_tags),
                        '@fields' => get_thread_current(:current_fields).merge(local_fields))
  end

  # rubocop:disable Metrics/MethodLength
  def self.compile_fields_and_tags(args)
    local_fields = {}
    local_tags = Set.new
    args.each do |arg|
      case arg
      when Hash
        local_fields.merge!(arg)
      when Symbol
        local_tags.add(arg)
      when Array
        local_tags.merge(arg)
      end
    end
    [local_fields, local_tags]
  end
  # rubocop:enable Metrics/MethodLength

  ['fatal', 'error', 'warn', 'info', 'debug'].each do |severity|
    # rubocop:disable Security/Eval
    eval <<-MULTILINE, nil, __FILE__, __LINE__ + 1
      def self.#{severity}(*args, &block)                 # def fatal(*args, &block)
        self.log(:#{severity}, *args, &block )            #   self.log('fatal', *args, &block)
      end                                                 # end
    MULTILINE
    # rubocop:enable Security/Eval
  end

  def self.tag(*tags)
    original_tags = get_thread_current(:current_tags)
    current_tags = original_tags.dup + tags.flatten
    set_thread_current(:current_tags, current_tags)
    yield
    set_thread_current(:current_tags, original_tags)
  end

  def self.metadata(*pairs)
    original_fields = get_thread_current(:current_fields) || {}
    current_fields = original_fields.dup
    pairs.flatten.each do |pair|
      pair.each do |k, v|
        current_fields[k.to_sym] = v
      end
    end
    set_thread_current(:current_fields, current_fields)
    yield
    set_thread_current(:current_fields, original_fields)
  end
end
