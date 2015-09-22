module Forms
  class PersonalInformation
    include Virtus.model
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = { last_name: String,
                             date_of_birth: Date,
                             married: Boolean,
                             title: String,
                             ni_number: String,
                             first_name: String }

    NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/

    # rubocop:disable AmbiguousOperator
    PERMITTED_ATTRIBUTES.each do |attr, type|
      attribute attr, type
    end

    def initialize(object)
      attrs = extract_params(object)
      super(attrs)
    end

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, inclusion: { in: [true, false] }
    validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true

    private

    def extract_params(object)
      get_attribs(object).select do |key, _|
        PERMITTED_ATTRIBUTES.include?(key.to_sym)
      end
    end

    def get_attribs(object)
      object.is_a?(Application) ? object.attributes : object
    end
  end
end
