module Forms
  module Application
    class LitigationDetail < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          litigation_friend_details: String
        }
      end

      define_attributes

      validates :litigation_friend_details, presence: true

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          litigation_friend_details: litigation_friend_details
        }
      end
    end
  end
end
