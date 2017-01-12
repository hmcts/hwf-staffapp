module Views
  module Reports
    class FinanceReportDataRow

      attr_accessor :office
      attr_accessor :jurisdiction
      attr_accessor :be_code
      attr_accessor :sop_code
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
      attr_accessor :none_count
      attr_accessor :none_sum

      def initialize(business_entity, date_from, date_to)
        @business_entity = business_entity
        @be_code = business_entity.code
        @office = business_entity.office.name
        @jurisdiction = business_entity.jurisdiction.name
        @date_from = date_from
        @date_to = date_to
        build_columns
      end

      private

      def build_columns
        build_totals
        build_benefit_income
        build_full_part
      end

      def build_totals
        @total_count = applications.count
        @total_sum = applications.sum(:decision_cost)
      end

      def build_benefit_income
        build_sum_and_count(grouped_application_types)
      end

      def build_full_part
        build_sum_and_count(grouped_decisions)
      end

      def build_sum_and_count(collection)
        count_data = collection.count
        count_data.each do |type|
          send("#{type[0]}_count=", type[1])
        end

        sum_data = collection.sum(:decision_cost)
        sum_data.each do |type|
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
          where(decision: %w[part full]).
          where(decision_date: @date_from..@date_to).
          where(business_entity_id: @business_entity.id).
          where(state: Application.states[:processed])
      end
    end
  end
end
