module Forms
  class BenefitsEvidence < ::FormObject
    extend ActiveModel::Callbacks
    define_model_callbacks :initialize, only: :before

    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :discretion_text

    def self.permitted_attributes
      {
        evidence: Symbol,
        correct: Boolean,
        incorrect_reason: String,
        discretion_value: Integer,
        discretion_reason: String
      }
    end

    define_attributes

    before_validation :define_discretion_text

    validates :evidence, inclusion: { in: %i[no yes discretion] }
    validates :correct, inclusion: { in: [true, false] }, if: 'evidence==:yes'
    validates :incorrect_reason, presence: true, if: '(evidence == :yes) && (correct? == false)'
    validates :discretion_value, presence: true, if: 'evidence == :discretion'
    validates :discretion_reason, presence: true, if: 'discretion_value == \'other\''

    private

    def define_discretion_text
      self[:discretion_text] = valid_discretion_response
    end

    def valid_discretion_response
      if self[:discretion_reason].present?
        self[:discretion_reason]
      elsif can_load_discretion_text_from_locale?
        array_value = self[:discretion_value] - 1
        I18n.t("discretion_options", scope: self[:i18n_scope])[array_value].values.first
      end
    end

    def can_load_discretion_text_from_locale?
      self[:discretion_value].present? && self[:discretion_value].to_i > 0
    end

    def fields_to_update
      # TODO: Add values for discretion to model and then save it here!
      { correct: correct, incorrect_reason: incorrect_reason }
    end

    def persist!
      unless evidence == :no
        @object.update(fields_to_update)
        @object.application.update(outcome: outcome)
      end
    end

    def outcome
      correct ? 'full' : 'none'
    end
  end
end
