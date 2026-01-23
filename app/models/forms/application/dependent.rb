module Forms
  module Application
    class Dependent < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          income: Integer,
          dependents: Boolean,
          children: Integer,
          children_age_band: Hash,
          children_age_band_one: Integer,
          children_age_band_two: Integer
        }
      end

      define_attributes
      before_validation :reset_children_fields
      before_validation :prepare_children_fields

      validates :income, presence: true, unless: proc { ucd_changes_apply?(@object.detail.calculation_scheme) }
      validates :income, numericality: { allow_blank: true }

      validates :dependents, inclusion: { in: [true, false] }

      validates :children, numericality: { greater_than: 0, only_integer: true }, if: proc { |obj| obj.dependents }

      # needed by pre ucd changes
      validates :children, numericality: { only_integer: true }, if: :dependents?
      validate :number_of_children_when_no_dependents

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          income: income,
          dependents: dependents,
          children: children,
          application_type: 'income',
          children_age_band: children_age_band
        }
      end

      def number_of_children_when_no_dependents
        if children_declared_but_dependents_arent?
          errors.add(
            :children,
            :cant_have_children_assigned
          )
        end
      end

      def children_declared_but_dependents_arent?
        !dependents && children.to_i.positive?
      end

      def prepare_children_fields
        return unless dependents
        return unless ucd_changes_apply?(@object.detail.calculation_scheme)
        self.children = band_one_value + band_two_value
        self.children_age_band = { one: band_one_value, two: band_two_value }

        if children <= 0
          errors.add(:children_age_band_one, :blank)
          errors.add(:children_age_band_two, :blank)
        end
      end

      def reset_children_fields
        return unless ucd_changes_apply?(@object.detail.calculation_scheme)
        return if dependents

        self.children = 0
        self.children_age_band = nil
      end

      def band_one_value
        return 0 if children_age_band_one.blank?
        children_age_band_one
      end

      def band_two_value
        return 0 if children_age_band_two.blank?
        children_age_band_two
      end
    end
  end
end
