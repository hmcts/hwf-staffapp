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

      def selected?(value)
        value == true || value.to_s == '1'
      end

      def build_query
        return sql_query unless selected?(@all_offices) || selected?(@all_datashare_offices)

        sql_query.
          sub("ORDER BY applications.created_at DESC", "ORDER BY offices.name ASC").
          sub("WHERE applications.office_id = #{@office_id}",
              "WHERE applications.office_id IN (#{office_ids.join(', ')})")
      end

      def office_ids
        if selected?(@all_offices)
          Office.pluck(:id)
        elsif selected?(@all_datashare_offices)
          codes = Settings.evidence_check.hmrc.office_entity_code
          Office.where(entity_code: codes).pluck(:id)
        else
          []
        end
      end
    end
  end
end
