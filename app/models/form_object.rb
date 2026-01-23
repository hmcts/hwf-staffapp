# Define type classes that Virtus provided but don't exist in plain Ruby
# These are used in permitted_attributes hashes across form classes
Decimal = Class.new unless defined?(Decimal)
Boolean = Class.new unless defined?(Boolean)

class FormObject
  include ActiveModel::Model
  include ActiveModel::Attributes

  TYPE_MAPPING = {
    String => :string,
    Integer => :integer,
    Decimal => :decimal,
    BigDecimal => :decimal,
    Boolean => :boolean,
    Date => :date,
    Float => :float
  }.freeze

  def initialize(object)
    store_if_model_passed(object)
    attrs = extract_params(object)
    super(attrs)
    nullify_blanks
  end

  def update(params)
    params.each do |name, value|
      public_send(:"#{name}=", value)
    end
    nullify_blanks
  end

  # Support hash-like access for backwards compatibility with Virtus
  def [](key)
    public_send(key)
  end

  def []=(key, value)
    public_send(:"#{key}=", value)
  end

  def self.permitted_attributes
    {}
  end

  def self.define_attributes
    permitted_attributes.each do |attr, type|
      # Handle Array type (Virtus used [] to define arrays)
      # Handle Hash type for complex objects
      # Check for: [] syntax, Array instances, Array class, or Hash class
      if type == [] || type.is_a?(Array) || type == Array || type == Hash
        # For arrays and hashes, we use a simple attr_accessor and skip type coercion
        attr_accessor attr
      else
        mapped_type = TYPE_MAPPING.fetch(type, :string)
        attribute attr, mapped_type

        # ActiveModel::Attributes doesn't create predicate methods for booleans
        # unlike ActiveRecord, so we need to define them manually
        if mapped_type == :boolean
          define_method(:"#{attr}?") { !!send(attr) }
        end
      end
    end
  end

  def nullify_blanks
    self.class.permitted_attributes.each_key do |attr|
      value = send(attr)
      send(:"#{attr}=", nil) if value.is_a?(String) && value.blank?
    end
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def i18n_scope
    :"activemodel.attributes.#{self.class.name.underscore}"
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
      self.class.permitted_attributes.key?(key.to_sym)
    end
  end

  def get_attribs(object)
    object.is_a?(ActiveRecord::Base) ? object.attributes : object
  end

  def ucd_changes_apply?(scheme)
    return false if scheme.blank?
    scheme == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
  end
end
