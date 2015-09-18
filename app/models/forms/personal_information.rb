module Forms
  class PersonalInformation
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[last_name date_of_birth married title ni_number first_name]
    NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/

    attr_accessor *PERMITTED_ATTRIBUTES

    def initialize(object)
      attrs = extract_params(object)
      super(attrs)
    end

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, presence: true
    validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true

    private

    def extract_params(object)
      if object.is_a? Application
        extract_from_class(object)
      elsif object.is_a? Hash
        extract_from_hash(object)
      end
    end

    def extract_from_class(object)
      object.attributes.select do |key, _|
        PERMITTED_ATTRIBUTES.include?(key.to_sym)
      end
    end

    def extract_from_hash(object)
      object.select do |key, _|
        PERMITTED_ATTRIBUTES.include?(key.to_sym)
      end
    end
  end
end
