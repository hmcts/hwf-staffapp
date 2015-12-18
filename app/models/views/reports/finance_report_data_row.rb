module Views
  module Reports
    class FinanceReportDataRow

      attr_accessor :office
      attr_accessor :jurisdiction
      attr_accessor :total_count
      attr_accessor :total_sum
      attr_accessor :full_count
      attr_accessor :full_sum
      attr_accessor :part_count
      attr_accessor :part_sum
      attr_accessor :benefit_count
      attr_accessor :benefit_sum
      attr_accessor :income_count
      attr_accessor :income_sum

      def initialize(business_entity, date_from, date_to)
        @business_entity = business_entity
        @office = business_entity.office.name
        @jurisdiction = business_entity.jurisdiction.name
        @date_from = date_from
        @date_to = date_to
        build_columns
      end

      private

      def build_columns
        build_totals
        build_benefit_income_count
        build_benefit_income_sum
        build_full_part_count
        build_full_part_sum
      end

      def build_totals
        @total_count = applications.count
        @total_sum = applications.sum(:decision_cost)
      end

      def build_benefit_income_count
        data = grouped_application_types.count
        data.each do |type|
          send("#{type[0]}_count=", type[1])
        end
      end

      def build_benefit_income_sum
        data = grouped_application_types.sum(:decision_cost)
        data.each do |type|
          send("#{type[0]}_sum=", type[1].to_s('F'))
        end
      end

      def build_full_part_count
        data = grouped_decisions.count
        data.each do |type|
          send("#{type[0]}_count=", type[1])
        end
      end

      def build_full_part_sum
        data = grouped_decisions.sum(:decision_cost)
        data.each do |type|
          send("#{type[0]}_sum=", type[1].to_s('F'))
        end
      end

      def grouped_application_types
        applications.group(:application_type)
      end

      def grouped_decisions
        applications.group(:decision)
      end

      def applications
        Application.
          select(:decision).
          where("decision IN ('part', 'full')").
          where('decision_date BETWEEN :d1 AND :d2', d1: @date_from, d2: @date_to).
          where(business_entity_id: @business_entity.id)
      end
    end
  end
end
