module Forms
  module Evidence
    class Income < ::FormObject

      def self.permitted_attributes
        {
          income: :string
        }
      end

      define_attributes

      validates :income, numericality: { greater_than_or_equal_to: 0 }

      private

      def formatted_income
        income.to_f.round
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        result = income_calculation
        {
          income: formatted_income,
          outcome: result[:outcome],
          amount_to_pay: result[:amount_to_pay]
        }
      end

      def income_calculation
        if ucd_apply?
          band_calculation
        else
          IncomeCalculation.new(@object.application, formatted_income.to_i).calculate
        end
      end

      def ucd_apply?
        FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == @object.application.detail.calculation_scheme
      end

      def band_calculation
        @object.application.income = formatted_income.to_i
        band = BandBaseCalculation.new(@object.application)
        { outcome: band.remission, amount_to_pay: band.amount_to_pay }
      end

    end
  end
end
