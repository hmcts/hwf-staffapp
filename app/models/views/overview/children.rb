module Views
  module Overview
    class Children < Views::Overview::Base

      def all_fields
        ['dependents', 'children_age_band']
      end

      def initialize(application)
        @application = application
      end

      def dependents
        convert_to_boolean(@application.dependents?)
      end

      def children_age_band
        return nil if @application.children_age_band.blank?
        one = @application.children_age_band[:one] || 0
        two = @application.children_age_band[:two] || 0
        return nil if one.zero? && two.zero?
        # rubocop:disable Rails/OutputSafety
        "#{one} (aged 0-13) <br />
         #{two} (aged 14+)".html_safe
        # rubocop:enable Rails/OutputSafety
      end

    end
  end
end
