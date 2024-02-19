module Forms
  module Application
    class IncomeKindPartner < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          income_kind: String,
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
          income_kind: @income_kind
        }
      end

      def none_of_above_selected
        if income_kind_partner.include?('20') && income_kind_partner.count > 1
          errors.add(:income_kind_partner, :invalid)
        end
      end

      def format_income_kind
        @income_kind = { applicant: income_kind_applicant, partner: income_kind_text_values(@income_kind_partner) }
      end

      def income_kind_text_values(kinds)
        scope = 'activemodel.attributes.forms/application/income_kind_partner'
        kinds.map do |kind|
          I18n.t(kind, scope: [scope, 'kinds'])
        end
      end

      def income_kind_applicant
        @income_kind.try(:[], :applicant) || []
      end
    end
  end
end
