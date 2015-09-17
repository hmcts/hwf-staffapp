module Forms
  class PersonalDetails
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[last_name date_of_birth married title ni_number first_name]

    attr_accessor *PERMITTED_ATTRIBUTES

    def initialize(application)
      attrs = application.attributes.select do |key, _|
        PERMITTED_ATTRIBUTES.include?(key.to_sym)
      end

      super(attrs)
    end

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, inclusion: { in: [true, false] }
  end
end
