module Evidence
  module Forms
    class Income < ::FormObject

      def self.permitted_attributes
        {
          income: String
        }
      end

      define_attributes

      validates :income, presence: true
      validates :income, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
