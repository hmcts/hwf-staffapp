module Forms
  module Application
    class Delete < ::FormObject
      def self.permitted_attributes
        { deleted_reason: String }
      end

      define_attributes

      validates :deleted_reason, presence: true

      private

      def persist!
        @object.update(deleted_reason: deleted_reason)
      end
    end
  end
end
