module Forms
  module Application
    class Remove < ::FormObject
      def self.permitted_attributes
        { removed_reason: String }
      end

      define_attributes

      validates :removed_reason, presence: true

      private

      def persist!
        @object.update(removed_reason: removed_reason)
      end
    end
  end
end
