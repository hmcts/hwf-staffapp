module Forms
  module Application
    class Applicant < ::FormObject

      MINIMUM_AGE = 16
      MAXIMUM_AGE = 120
      NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
      HO_NUMBER_REGEXP = %r{\A([a-zA-Z]\d{7}|\d{4}-\d{4}-\d{4}-\d{4})(/\d{1,})?\z}
      include ActiveModel::Validations::Callbacks

      # rubocop:disable Metrics/MethodLength
      def self.permitted_attributes
        {
          last_name: String,
          date_of_birth: Date,
          day_date_of_birth: Integer,
          month_date_of_birth: Integer,
          year_date_of_birth: Integer,
          married: Boolean,
          title: String,
          ni_number: String,
          ho_number: String,
          first_name: String,
          date_received: Date
        }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      before_validation :format_ni_number, :format_ho_number
      before_validation :strip_whitespace!
      before_validation :format_dob

      validates :first_name, presence: true
      validates :first_name, length: { minimum: 2 }, allow_blank: true

      validates :last_name, presence: true
      validates :last_name, length: { minimum: 2 }, allow_blank: true
      validate :dob_age_valid?
      validates :married, inclusion: { in: [true, false] }
      validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true
      validates :ho_number, format: { with: HO_NUMBER_REGEXP }, allow_blank: true

      def format_ni_number
        unless ni_number.nil?
          ni_number.upcase!
          ni_number.delete!(' ')
        end
      end

      def format_ho_number
        unless ho_number.nil?
          ho_number.upcase!
          ho_number.delete!(' ')
        end
      end

      def format_dob
        self.date_of_birth = concat_dob_dates.to_date
      rescue StandardError
        self.date_of_birth = concat_dob_dates
      end

      def concat_dob_dates
        return nil if day_date_of_birth.blank? || month_date_of_birth.blank? ||
                      month_date_of_birth.blank?
        "#{day_date_of_birth}/#{month_date_of_birth}/#{year_date_of_birth}"
      end

      def day_date_of_birth
        attributes['day_date_of_birth'] || date_of_birth&.day
      end

      def month_date_of_birth
        attributes['month_date_of_birth'] || date_of_birth&.month
      end

      def year_date_of_birth
        attributes['year_date_of_birth'] || date_of_birth&.year
      end

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
        if /[a-zA-Z]/.match?(date_of_birth.try(:to_fs, :db))
          errors.add(:date_of_birth, "can't contain non numbers")
        elsif !date_of_birth.is_a?(Date)
          errors.add(:date_of_birth, :not_a_date)
        end
      end

      def too_young?
        date_of_birth > Time.zone.today
      end

      def too_old?
        date_of_birth < (Time.zone.today - MAXIMUM_AGE.years)
      end

      def same_submit_date?
        date_of_birth == date_received
      end

      def too_young_error
        errors.add(:date_of_birth, :too_young, minimum_age: MINIMUM_AGE)
      end

      def too_old_error
        errors.add(:date_of_birth, :too_old, maximum_age: MAXIMUM_AGE)
      end

      def same_submit_date_error
        errors.add(:date_of_birth, :same_submit_date)
      end

      def validate_dob_ranges
        too_young_error if too_young?
        too_old_error if too_old?
        same_submit_date_error if same_submit_date?
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          title: title,
          last_name: last_name,
          first_name: first_name,
          date_of_birth: format_dob,
          married: married,
          ni_number: ni_number,
          ho_number: ho_number
        }
      end
    end
  end
end
