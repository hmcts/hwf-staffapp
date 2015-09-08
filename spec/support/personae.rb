module Personae
  class Persona < OpenStruct
  end

  def married_under_61
    data = personal_details(1, married: true, over_61: false)
    Persona.new(data)
  end

  def single_under_61
    data = personal_details(
      1,
      last_name: 'Smith',
      married: false,
      over_61: false,
      ni_number: 'AB123456A',
      savings_exceeded: true
    )
    Persona.new(data)
  end

  def single_under_61_complete
    data = personal_details(1, married: false, over_61: false)
    Persona.new(data)
  end

  module_function

  def all_personae
    result = []
    opts = {}
    opts[:married] = [true, false]
    opts[:over_61] = [true, false]
    opts[:ni_number] = ['', 'AB123456A']
    opts[:threshold_exceeded] = [true, false]

    product_hash(opts).each_with_index do |outcome, index|
      result << Persona.new(personal_details(index, outcome))
    end
    result
  end

  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map { |p| Hash[keys.zip p] }
  end

  def personal_details(id, options = {})
    now = Time.zone.now
    {
      id: id + 1,
      persona_name: persona_name(options),
      created_at: now,
      title: 'Mr',
      first_names: 'Placeholder',
      ni_number: options[:ni_number],
      last_name: 'Hirani',
      married: options[:married],
      threshold_exceeded: options[:threshold_exceeded],
      date_of_birth: generate_dob(options[:over_61]),
      over_61: options[:over_61],
      date_received: now - 1.day,
      our_api_token: "@#{now.strftime('%y%m%d%H%M%S')}.1"
    }
  end

  def persona_name(options = {})
    options.delete(:id)
    matches = options.delete_if { |_k, v| v.to_s.nil? || v.to_s == 'false' }
    result = matches.map do |k, v|
      case v.to_s
      when 'true'
        "#{k}"
      when v.to_s.empty?
        "#{k} is empty"
      else
        "#{k} is #{v}"
      end
    end
    result.to_sentence(last_word_connector: ' and ')
  end

  def generate_dob(over_61)
    Time.zone.now - (over_61 == true ? 65 : 20).years
  end
end
