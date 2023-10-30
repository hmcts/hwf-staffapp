module Views
  module Overview
    class Declaration
      include ActionView::Helpers::NumberHelper

      def initialize(application)
        @application = application
      end

      def all_fields
        [
          'statement_signed_by'
        ]
      end

      def statement_signed_by
        return '' if detail.statement_signed_by.blank?
        scope = 'activemodel.attributes.views/overview/declaration'
        I18n.t(".#{detail.statement_signed_by}", scope: scope)
      end

      private

      def detail
        @application.detail
      end
    end
  end
end
