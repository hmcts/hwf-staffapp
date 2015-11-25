module Forms
  module Application
    class PersonalInformation < ::FormObject

      MINIMUM_AGE = 16
      MAXIMUM_AGE = 120
      MIN_DOB = Time.zone.today - MINIMUM_AGE.years
      MAX_DOB = Time.zone.today - MAXIMUM_AGE.years
      NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          last_name: String,
          date_of_birth: Date,
          married: Boolean,
          title: String,
          ni_number: String,
          first_name: String
        }
      end

      define_attributes

      before_validation :format_ni_number

      def format_ni_number
        unless ni_number.nil?
          ni_number.upcase!
          ni_number.gsub!(' ', '')
        end
      end

      validates :last_name, presence: true, length: { minimum: 2 }
      validates :date_of_birth, presence: true
      validate :dob_age_valid?
      validates :married, inclusion: { in: [true, false] }
      validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true

      private

      def dob_age_valid?
        validate_dob
        validate_dob_ranges unless errors.include?(:date_of_birth)
      end

      def validate_dob
        if date_of_birth =~ /[a-zA-Z]/
          errors.add(:date_of_birth, "can't contain non numbers")
        elsif !date_of_birth.is_a?(Date)
          errors.add(:date_of_birth, :not_a_date)
        end
      end

      def validate_dob_ranges
        if date_of_birth > MIN_DOB
          errors.add(:date_of_birth, :too_young, minimum_age: MINIMUM_AGE)
        elsif date_of_birth < MAX_DOB
          errors.add(:date_of_birth, :too_old, maximum_age: MAXIMUM_AGE)
        end
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          title: title,
          last_name: last_name,
          first_name: first_name,
          date_of_birth: date_of_birth,
          married: married,
          ni_number: ni_number
        }
      end
    end
  end
end
