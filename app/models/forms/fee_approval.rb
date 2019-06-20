module Forms
  class FeeApproval < ::FormObject
    def self.permitted_attributes
      {
        fee_manager_firstname: String,
        fee_manager_lastname: String
      }
    end

    define_attributes

    validates :fee_manager_firstname, :fee_manager_lastname, presence: true

    private

    def fields_to_update
      { fee_manager_firstname: fee_manager_firstname, fee_manager_lastname: fee_manager_lastname }
    end

    def persist!
      @object.update(fields_to_update)
    end
  end
end
