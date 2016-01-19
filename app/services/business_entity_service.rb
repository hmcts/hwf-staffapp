class BusinessEntityService

  def initialize(office, jurisdiction)
    @office = office
    @jurisdiction = jurisdiction
    @timestamp = Time.zone.now
    @business_entity = BusinessEntity.find_by(office: office,
                                              jurisdiction: jurisdiction,
                                              valid_to: nil)
  end

  def build(params)
    build_business_entity(params)
  end

  def check_update(params)
    build_business_entity(params)
  end

  def persist_update!(business_entity)
    return false if business_entity.nil? || @business_entity.nil?
    if duplicate_needed?(business_entity)
      @business_entity.assign_attributes(valid_to: @timestamp)
      save_entities_in_transaction(business_entity)
    else
      @business_entity.assign_attributes(name: business_entity.name)
      @business_entity.save
    end
  end

  def deactivate
    @business_entity.assign_attributes(valid_to: @timestamp)
    @business_entity
  end

  private

  def build_business_entity(params)
    BusinessEntity.new(office: @office,
                       jurisdiction: @jurisdiction,
                       name: params[:name],
                       code: params[:code],
                       valid_from: @timestamp)
  end

  def duplicate_needed?(business_entity)
    business_entity != @business_entity &&
      (both_entities_present?(business_entity) && business_entity.code != @business_entity.code)
  end

  def both_entities_present?(business_entity)
    @business_entity.present? && business_entity.present?
  end

  def save_entities_in_transaction(business_entity)
    ActiveRecord::Base.transaction do
      @business_entity.save
      business_entity.save
    end
  end
end
