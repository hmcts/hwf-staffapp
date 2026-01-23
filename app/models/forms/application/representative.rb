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
      validate :special_characters_check

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

      def special_characters_check
        self.class.permitted_attributes.each_key do |name|
          next if contains_only_standard_characters?(send(name))
          errors.add(name, 'Must not contain special characters')
        end
      end

      def contains_only_standard_characters?(string)
        return true if string.blank?
        /\A[\w\s]+\z/.match?(string)
      end

    end
  end
end
