module Forms
  module Application
    class Income < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          income: Integer,
          income_period: String
        }
      end

      define_attributes

      validates :income, presence: true, unless: proc { ucd_changes_apply?(@object.detail.calculation_scheme) }
      validates :income, numericality: { allow_blank: true }
      validates :income_period, presence: true

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          income: income,
          application_type: 'income',
          income_period: income_period
        }
      end
    end
  end
end
