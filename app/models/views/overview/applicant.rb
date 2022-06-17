module Views
  module Overview
    class Applicant

      delegate(:full_name, to: :applicant)
      delegate(:ho_number, to: :applicant)

      def initialize(application)
        @application = application
      end

      def all_fields
        ['full_name', 'date_of_birth', 'under_age', 'ni_number', 'ho_number', 'status']
      end

      def ni_number
        applicant.ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def status
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        I18n.t("married_#{applicant.married?}", scope: locale_scope)
      end

      def date_of_birth
        format_date applicant.date_of_birth
      end

      def under_age
        return unless applicant.under_age?
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        I18n.t("under_age_true", scope: locale_scope)
      end

      private

      def applicant
        @application.applicant
      end

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end
    end
  end
end
