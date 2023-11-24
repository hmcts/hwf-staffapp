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

      def children
        convert_to_boolean(@application.children?)
      end

      def children_age_band
        return nil if @application.children_age_band.blank?
        one = age_band_value(1)
        two = age_band_value(2)
        return nil if one.zero? && two.zero?
        # rubocop:disable Rails/OutputSafety
        "#{one} (aged 0-13) <br />
         #{two} (aged 14+)".html_safe
        # rubocop:enable Rails/OutputSafety
      end

      private

      def age_band_value(band_name)
        band = @application.children_age_band

        case band_name
        when 1
          (band[:one] || band['one'] || 0).to_i
        when 2
          (band[:two] || band['two'] || 0).to_i
        end
      end

    end
  end
end
