module Forms
  module Application
    class Representative < ::FormObject
      def self.permitted_attributes
        {
          first_name: String,
          last_name: String,
          organisation: String
        }
      end

      define_attributes

      validates :first_name, presence: true
      validates :last_name, presence: true

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
    end
  end
end
