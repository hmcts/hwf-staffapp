module Forms
  module Application
    class Declaration < ::FormObject
      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          statement_signed_by: :string,
          discretion_applied: :boolean
        }
      end
      define_attributes

      before_validation :reset_representative
      validates :statement_signed_by, presence: true

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {}.tap do |fields|
          self.class.permitted_attributes.each_key do |name|
            fields[name] = send(name)
          end
        end
      end

      def reset_representative
        if statement_signed_by == 'applicant' && @object.application.representative
          @object.application.representative.destroy
        end
      end
    end
  end
end
