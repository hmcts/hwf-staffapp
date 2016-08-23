class UpdateMissingBusinessEntities

  def self.affected_records
    Application.
      joins(:detail).
      where(business_entity_id: nil).
      where.not(
        reference: nil,
        office_id: nil,
        'details.jurisdiction_id': nil
      )
  end

  def self.up!
    affected_records.each do |application|
      application.update(BusinessEntityGenerator.new(application).attributes)
    end
  end
end
