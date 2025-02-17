module Views
  module Overview
    class OnlineApplicant

      def initialize(application)
        @application = application
      end

      def all_fields
        ['full_name', 'date_of_birth', 'under_age', 'ni_number', 'ho_number', 'status',
         'partner_full_name', 'partner_date_of_birth', 'partner_ni_number']
      end

      def partner_full_name
        [@application.partner_first_name, @application.partner_last_name].compact_blank.join(' ')
      end

      def full_name
        [@application.first_name, @application.last_name].compact_blank.join(' ')
      end

      def ni_number
        @application.ni_number&.gsub(/(.{2})/, '\1 ')
      end

      delegate :ho_number, to: :@application

      def partner_ni_number
        @application.partner_ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def status
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        I18n.t("married_#{@application.married?}", scope: locale_scope)
      end

      def date_of_birth
        format_date @application.date_of_birth
      end

      def partner_date_of_birth
        # temporary fix for dob from partner - should be nil
        return nil if @application.partner_first_name.nil?
        format_date @application.partner_date_of_birth
      end

      def under_age
        return if @application.over_16.nil?
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        if @application.over_16
          I18n.t("over_16_true", scope: locale_scope)
        else
          I18n.t("over_16_false", scope: locale_scope)
        end
      end

      private

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end
    end
  end
end
