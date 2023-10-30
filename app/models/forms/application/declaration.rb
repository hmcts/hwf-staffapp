module Forms
  module Application
    class Declaration < ::FormObject
      include ActiveModel::Validations::Callbacks

      # rubocop:disable Metrics/MethodLength
      def self.permitted_attributes
        {
          statement_signed_by: String,
          discretion_applied: Boolean
        }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      validates :statement_signed_by, presence: true

      private


      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {}.tap do |fields|
          (self.class.permitted_attributes.keys).each do |name|
            fields[name] = send(name)
          end
        end
      end
    end
  end
end
