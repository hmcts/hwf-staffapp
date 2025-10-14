module Views
  module Overview
    module IncomeHelper

      def income_result
        return if @application.application_type != "income"
        format_locale(['full', 'part'].include?(result).to_s)
      end

      def income_kind_applicant
        translate_kinds(:applicant)
      end

      def income_kind_partner
        translate_kinds(:partner)
      end

      def translate_kinds(person)
        return if @application.income_kind.nil? || @application.income_kind[person].blank?

        IncomeTypesInput.normalize_list(@application.income_kind[person]).map do |kind|
          I18n.t(kind, scope: ["activemodel.attributes.forms/application/income_kind_#{person}", 'kinds'])
        end.join(', ')
      end

      def income_period
        return if @application.income_period.nil?
        scope = 'activemodel.attributes.views/overview/application'
        I18n.t("income_period_#{@application.income_period}", scope: scope)
      end

    end
  end
end
