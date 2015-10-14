class FormObject
  include Virtus.model(nullify_blank: true)
  include ActiveModel::Model

  def initialize(object)
    store_if_model_passed(object)
    attrs = extract_params(object)
    super(attrs)
  end

  def update_attributes(params)
    params.each do |name, value|
      public_send("#{name}=", value)
    end
  end

  def self.permitted_attributes
    {}
  end

  def self.define_attributes
    permitted_attributes.each { |attr, type| attribute attr, type }
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    raise NotImplementedError
  end

  def store_if_model_passed(object)
    @object = object if object.is_a?(ActiveRecord::Base)
  end

  def extract_params(object)
    get_attribs(object).select do |key, _|
      self.class.permitted_attributes.keys.include?(key.to_sym)
    end
  end

  def get_attribs(object)
    object.is_a?(ActiveRecord::Base) ? object.attributes : object
  end
end
