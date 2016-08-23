class BusinessEntityGenerator
  def initialize(application)
    @application = application
  end

  def attributes
    { business_entity: business_entity }
  end

  private

  def business_entity
    @business_entity ||=
      BusinessEntity.current_for(@application.office, @application.detail.jurisdiction)
  end
end
