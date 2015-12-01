module Views
  module Overview
    class Benefits < Base

      def all_fields
        %w[on_benefits? override? override_valid?]
      end

      def initialize(application)
        @application = application
      end

      def on_benefits?
        convert_to_boolean(@application.benefits?)
      end

      def override?
        convert_to_boolean(benefit_overridden?) if @application.benefits?
      end

      def override_valid?
        if @application.benefits? && benefit_overridden?
          convert_to_boolean(@application.benefit_override.correct)
        end
      end

      private

      def benefit_overridden?
        !@application.benefit_override.nil?
      end
    end
  end
end
