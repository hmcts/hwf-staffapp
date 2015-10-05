class FormObject
  include Virtus.model(nullify_blank: true)
  include ActiveModel::Model

  def initialize(object)
    attrs = extract_params(object)
    super(attrs)
  end

  def self.permitted_attributes
    {}
  end

  def self.define_attributes
    permitted_attributes.each { |attr, type| attribute attr, type }
  end

  private

  def extract_params(object)
    get_attribs(object).select do |key, _|
      self.class.permitted_attributes.keys.include?(key.to_sym)
    end
  end

  def get_attribs(object)
    object.is_a?(Application) ? object.attributes : object
  end
end
