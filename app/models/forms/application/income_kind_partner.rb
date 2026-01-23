module Forms
  module Application
    class IncomeKindPartner < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          income_kind: Hash,
          income_kind_partner: []
        }
      end

      define_attributes

      before_validation :format_income_kind
      validates :income_kind_partner, presence: true
      validate :none_of_above_selected

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          income_kind: income_kind
        }
      end

      def none_of_above_selected
        return if income_kind_partner.blank?
        if income_kind_partner.include?('none_of_the_above') && income_kind_partner.count > 1
          errors.add(:income_kind_partner, :invalid)
        end
      end

      def format_income_kind
        self.income_kind = { applicant: income_kind_applicant_value,
                             partner: income_kind_partner }.with_indifferent_access
      end

      def income_kind_applicant_value
        income_kind.try(:[], :applicant) || []
      end
    end
  end
end
