module Forms
  class PersonalDetails
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[last_name date_of_birth married title ni_number first_name]

    attr_accessor *PERMITTED_ATTRIBUTES

    def initialize(object)
      attrs = extract_params(object)
      super(attrs)
    end

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, inclusion: { in: [true, false] }

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
