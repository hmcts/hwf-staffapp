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
    end
  end
end
