module Forms
  module Application
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

      def fields_to_update # rubocop:disable Metrics/AbcSize
        {
          benefits: benefits
        }.tap do |fields|
          fields[:application_type] = benefits? ? 'benefit' : 'income'
          fields[:dependents] = nil if benefits?
          fields[:outcome] = benefit_check.presence&.outcome
          fields[:income_kind] = nil if benefits?
          fields[:income] = nil if benefits?
          fields[:income_period] = nil if benefits?
        end
      end

      def benefit_check
        @object.last_benefit_check
      end
    end
  end
end
