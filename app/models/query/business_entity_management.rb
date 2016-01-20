module Query
  class BusinessEntityManagement
    def initialize(office)
      @office = office
    end

    def jurisdictions
      Jurisdiction.all.map do |jurisdiction|
        Views::OfficeBusinessEntityState.new(@office, jurisdiction)
      end
    end
  end
end
