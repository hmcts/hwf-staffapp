module Evidence
  module Forms
    class Evidence < ::FormObject

      def self.permitted_attributes
        {
          correct: Boolean
        }
      end

      define_attributes

      validates :correct, inclusion: { in: [true, false] }

    end
  end
end
