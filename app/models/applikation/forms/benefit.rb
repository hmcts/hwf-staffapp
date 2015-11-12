module Applikation
  module Forms
    class Benefit < ::FormObject
      def self.permitted_attributes
        { benefits: Boolean }
      end

      define_attributes

      validates :benefits, inclusion: { in: [true, false] }

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          benefits: benefits
        }.tap do |fields|
          fields[:application_type] = benefits? ? 'benefit' : 'income'
          fields[:dependents] = nil if benefits?
          fields[:outcome] = benefit_check.present? ? benefit_check.outcome : nil
        end
      end

      def benefit_check
        @object.last_benefit_check
      end
    end
  end
end
