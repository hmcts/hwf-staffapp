module Evidence
  module Forms
    class Income < ::FormObject

      def self.permitted_attributes
        {
          amount: String
        }
      end

      define_attributes

      validates :amount, presence: true
      validates :amount, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
