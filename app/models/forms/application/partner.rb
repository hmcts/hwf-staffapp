module Forms
  module Application
    class Partner < ::FormObject

      MINIMUM_AGE = 16
      MAXIMUM_AGE = 120
      NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
      HO_NUMBER_REGEXP = %r{\A([a-zA-Z]\d{7}|\d{4}-\d{4}-\d{4}-\d{4})(/\d{1,})?\z}
      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          partner_first_name: :string,
          partner_last_name: :string,
          partner_date_of_birth: :date,
          day_date_of_birth: :integer,
          month_date_of_birth: :integer,
          year_date_of_birth: :integer,
          partner_ni_number: :string,
          ni_number: :string
        }
      end
      define_attributes

      before_validation :format_ni_number
      before_validation :strip_whitespace!
      before_validation :format_dob

      validates :partner_first_name, length: { minimum: 2 }, allow_blank: true
      validates :partner_last_name, length: { minimum: 2 }, allow_blank: true
      validates :partner_ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true
      validate :dob_age_valid?
      validate :ni_number_duplicate

      def format_ni_number
        unless partner_ni_number.nil?
          partner_ni_number.upcase!
          partner_ni_number.delete!(' ')
        end
      end

      def ni_number_duplicate
        if ni_number.present? && ni_number == partner_ni_number
          errors.add(:partner_ni_number, :duplicate)
        end
      end

      def format_dob
        self.partner_date_of_birth = nil
        self.partner_date_of_birth = concat_dob_dates.to_date unless check_dob_entered
      rescue StandardError
        errors.add(:partner_date_of_birth, :not_a_date)
      end

      def concat_dob_dates
        return nil if check_dob_entered

        "#{day_date_of_birth}/#{month_date_of_birth}/#{year_date_of_birth}"
      end

      def check_dob_entered
        day_date_of_birth.blank? || month_date_of_birth.blank? || year_date_of_birth.blank?
      end

      def day_date_of_birth
        attributes['day_date_of_birth'] || partner_date_of_birth&.day
      end

      def month_date_of_birth
        attributes['month_date_of_birth'] || partner_date_of_birth&.month
      end

      def year_date_of_birth
        attributes['year_date_of_birth'] || partner_date_of_birth&.year
      end

      private

      def strip_whitespace!
        partner_first_name&.strip!
        partner_last_name&.strip!
      end

      def dob_age_valid?
        return false if errors.include?(:partner_date_of_birth)
        validate_dob
        validate_dob_ranges
      end

      def validate_dob
        return if partner_date_of_birth.nil?

        if /[a-zA-Z]/.match?(partner_date_of_birth.try(:to_fs, :db))
          errors.add(:partner_date_of_birth, "can't contain non numbers")
        elsif !partner_date_of_birth.is_a?(Date)
          errors.add(:partner_date_of_birth, :not_a_date)
        end
      end

      def too_young?
        return false if partner_date_of_birth.nil?

        partner_date_of_birth > Time.zone.today
      end

      def too_old?
        return false if partner_date_of_birth.nil?

        partner_date_of_birth < (Time.zone.today - MAXIMUM_AGE.years)
      end

      def too_young_error
        errors.add(:partner_date_of_birth, :too_young, minimum_age: MINIMUM_AGE)
      end

      def too_old_error
        errors.add(:partner_date_of_birth, :too_old, maximum_age: MAXIMUM_AGE)
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
          partner_last_name: partner_last_name,
          partner_first_name: partner_first_name,
          partner_date_of_birth: format_dob,
          partner_ni_number: partner_ni_number
        }
      end
    end
  end
end
