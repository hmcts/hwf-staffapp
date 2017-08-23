module Views
  module Overview
    class Applicant

      delegate(:full_name, to: :applicant)

      def initialize(application)
        @application = application
      end

      def all_fields
        ['full_name', 'date_of_birth', 'ni_number', 'status']
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

      private

      def applicant
        @application.applicant
      end

      def format_date(date)
        date&.to_s(:gov_uk_long)
      end
    end
  end
end
