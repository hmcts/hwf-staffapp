module I18n
  # Implemented to support method call on translation keys
  INTERPOLATION_WITH_METHOD_PATTERN = Regexp.union(
    /%%/,
    /%\{(\w+)\}/,
    /%<(\w+)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/,
    /%\{(\w+)\.(\w+)\}/
  )

  class << self
    def interpolate_hash(string, values)
      string.gsub(INTERPOLATION_WITH_METHOD_PATTERN) do |match|
        if match == '%%'
          '%'
        else
          @last_match = Regexp.last_match
          process_value(string, values)
        end
      end
    end

    def process_value(string, values)
      @key = build_key
      if values.key?(@key)
        value = values[@key]
        value = value.call(values) if value.respond_to?(:call)
        build_value(value)
      else
        raise(MissingInterpolationArgument.new(values, string, ''))
      end
    end

    def build_key
      (@last_match[1] || @last_match[2] || @last_match[4]).to_sym
    end

    def build_value(value)
      if @last_match[3]
        sprintf("%#{@last_match[3]}", value)
      elsif @last_match[5]
        value.send(@last_match[5])
      else
        value
      end
    end
  end
end
