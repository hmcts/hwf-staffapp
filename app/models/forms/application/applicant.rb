module Forms
  module Application
    class Applicant < ::FormObject

      MINIMUM_AGE = 16
      MAXIMUM_AGE = 120
      # rubocop:disable MutableConstant
      NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
      # rubocop:enable MutableConstant
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
      before_validation :strip_whitespace!

      def format_ni_number
        unless ni_number.nil?
          ni_number.upcase!
          ni_number.delete!(' ')
        end
      end

      validates :last_name, presence: true, length: { minimum: 2, allow_blank: true }
      validate :dob_age_valid?
      validates :married, inclusion: { in: [true, false] }
      validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true

      private

      def strip_whitespace!
        title&.strip!
        first_name&.strip!
        last_name&.strip!
      end

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

      def too_young?
        date_of_birth > (Time.zone.today - MINIMUM_AGE.years)
      end

      def too_old?
        date_of_birth < (Time.zone.today - MAXIMUM_AGE.years)
      end

      def too_young_error
        errors.add(:date_of_birth, :too_young, minimum_age: MINIMUM_AGE)
      end

      def too_old_error
        errors.add(:date_of_birth, :too_old, maximum_age: MAXIMUM_AGE)
      end

      def validate_dob_ranges
        too_young_error if too_young?
        too_old_error if too_old?
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
