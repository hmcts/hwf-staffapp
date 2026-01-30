module Forms
  module Application
    class Delete < ::FormObject
      def self.permitted_attributes
        {
          deleted_reasons_list: :string,
          deleted_reason: :string
        }
      end

      define_attributes

      validates :deleted_reasons_list, presence: true
      validates :deleted_reason, presence: true, if: proc { description_required_reason_selected? }

      private

      def persist!
        @object.update(deleted_reasons_list: deleted_reasons_list,
                       deleted_reason: deleted_reason)
      end

      def description_required_reason_selected?
        ['Other error made by office processing application', 'Multiple applicants for one court application',
         'Unable to proceed with main court application'].include?(deleted_reasons_list)
      end
    end
  end
end
