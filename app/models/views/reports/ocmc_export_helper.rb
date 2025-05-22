module Views
  module Reports
    module OcmcExportHelper

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

      # rubocop:disable Metrics/MethodLength
      def build_query
        if @all_datashare_offices
          sql_query.
            sub("ORDER BY applications.created_at DESC", "ORDER BY offices.name ASC").
            sub("WHERE applications.office_id = #{@office_id}",
                "WHERE applications.office_id IN (#{Office.pluck(:id).join(', ')})")
        elsif @all_offices
          sql_query.
            sub("ORDER BY applications.created_at DESC", "ORDER BY offices.name ASC").
            sub("WHERE applications.office_id = #{@office_id}")
        else
          sql_query
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
