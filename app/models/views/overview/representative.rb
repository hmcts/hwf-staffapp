module Views
  module Overview
    class Representative
      include ActionView::Helpers::NumberHelper
      delegate(:first_name, :last_name, :organisation, to: :@representative)

      def initialize(representative)
        @representative = representative
      end

      def all_fields
        [
          'full_name', 'organisation'
        ]
      end

      def full_name
        return if @representative.blank?

        "#{@representative.first_name} #{@representative.last_name}".strip
      end

      # TODO: not working for online appl
      def display_section?
        @representative.present?
      end
    end
  end
end
