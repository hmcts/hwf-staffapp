module Views
  module Reports
    module ApplicationsByCourtExportHelper

      def data
        @data ||= build_data
      end

      def build_data
        query = build_query
        ActiveRecord::Base.connection.execute(query)
      end

      def children_age_band(value, attr_key)
        return 'N/A' if age_bands_blank?(value)

        hash_value = YAML.safe_load(value, permitted_classes: [Symbol, ActiveSupport::HashWithIndifferentAccess])
        if attr_key == :children_age_band_one
          hash_value[:one] || hash_value['one']
        elsif attr_key == :children_age_band_two
          hash_value[:two] || hash_value['two']
        end
      end

      def age_bands_blank?(value)
        return true if value.blank?

        hash_value = YAML.safe_load(value, permitted_classes: [Symbol, ActiveSupport::HashWithIndifferentAccess])
        hash_value.keys.select do |key|
          ['one', 'two'].include?(key.to_s)
        end.blank?
      end

      private

      def selected?(value)
        value == true || value.to_s == '1'
      end

      # Office scoping is handled in the SELECT (see paper_office_filter /
      # online_office_filter); here we only switch the sort to office name when
      # the report spans all offices.
      def build_query
        return sql_query unless selected?(@all_offices)

        sql_query.sub("ORDER BY applications.created_at DESC", "ORDER BY offices.name ASC")
      end
    end
  end
end
