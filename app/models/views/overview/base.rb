module Views
  module Overview
    class Base

      private

      def convert_to_boolean(input)
        I18n.t("convert_boolean.#{input.presence || 'false'}")
      end
    end
  end
end
