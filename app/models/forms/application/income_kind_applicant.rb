module Forms
  module Application
    class IncomeKindApplicant < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          income_kind: String,
          income_kind_applicant: []
        }
      end

      define_attributes

      before_validation :format_income_kind
      validates :income_kind_applicant, presence: true
      validate :none_of_above_selected
      validate :child_benefit_without_children

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          income_kind: @income_kind
        }
      end

      def none_of_above_selected
        if income_kind_applicant.include?('none_of_the_above') && income_kind_applicant.count > 1
          errors.add(:income_kind_applicant, :invalid)
        end
      end

      def child_benefit_without_children
        if income_kind_applicant.include?('child_benefit') && @object.children.to_i.zero?
          errors.add(:income_kind_applicant, :child_benefit_without_children)
        end
      end

      def format_income_kind
        @income_kind = { applicant: @income_kind_applicant, partner: income_kind_partner }.with_indifferent_access
      end

      def income_kind_partner
        @income_kind.try(:[], :partner) || []
      end
    end
  end
end
