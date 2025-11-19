module Views
  module Overview
    class Benefits < Base

      def all_fields
        ['on_benefits?', 'override?']
      end

      def initialize(application)
        @application = application
      end

      def on_benefits?
        convert_to_boolean(@application.benefits?)
      end

      # provided correct evidenece or DWP says yes
      def override?
        return false unless @application.benefits?

        if benefit_overridden?
          convert_to_boolean(@application.benefit_override.correct)
        else
          convert_to_boolean(@application.last_benefit_check&.passed?)
        end
      end

      private

      def benefit_overridden?
        !@application.benefit_override.nil?
      end

      def hide_when_discretion_applied?
        @application.detail.try(:discretion_applied) != nil
      end
    end
  end
end
