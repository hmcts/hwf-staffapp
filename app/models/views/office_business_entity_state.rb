module Views
  class OfficeBusinessEntityState
    def initialize(office, jurisdiction)
      @office = office
      @jurisdiction = jurisdiction
      @business_entity = BusinessEntity.current_for(office, jurisdiction)
      @office_jurisdiction = OfficeJurisdiction.find_by(office: office, jurisdiction: jurisdiction)
    end

    def jurisdiction_id
      @jurisdiction.id
    end

    def jurisdiction_name
      @jurisdiction.name
    end

    def business_entity_id
      @business_entity.id if @business_entity
    end

    def business_entity_code
      @business_entity.code if @business_entity
    end

    def business_entity_name
      @business_entity.name if @business_entity
    end

    def status
      if can_be_deleted?
        'delete'
      elsif can_be_updated?
        'edit'
      elsif can_be_added?
        'add'
      end
    end

    private

    def can_be_updated?
      @office_jurisdiction && @business_entity
    end

    def can_be_deleted?
      @office_jurisdiction.nil? && @business_entity
    end

    def can_be_added?
      @business_entity.nil?
    end
  end
end
