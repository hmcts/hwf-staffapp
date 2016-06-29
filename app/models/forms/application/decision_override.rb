module Forms
  module Application
    class DecisionOverride < ::FormObject
      def self.permitted_attributes
        {
          value: Integer,
          reason: String,
          created_by_id: Integer
        }
      end

      define_attributes

      validates :created_by_id, presence: true
      validates :value, presence: true
      validates :reason, presence: true, length: { maximum: 500 }, if: :reason_required?

      private

      def reason_required?
        value == 'other'
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        { reason: reason_text, user_id: created_by_id }
      end

      def reason_text
        if self[:reason].present?
          self[:reason]
        elsif can_load_text_from_locale?
          array_value = self[:value] - 1
          I18n.t("options", scope: self[:i18n_scope])[array_value].values.first
        end
      end

      def can_load_text_from_locale?
        self[:value].present? && self[:value].to_i > 0
      end
    end
  end
end
