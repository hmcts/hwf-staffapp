class BusinessEntityService

  def initialize(office, jurisdiction)
    @office = office
    @jurisdiction = jurisdiction
    @timestamp = Time.zone.now
    @existing_business_entity = BusinessEntity.current_for(office, jurisdiction)
  end

  # TODO: deprecate
  def check_update(params)
    build_business_entity(params)
  end

  def build_new(params)
    @new_params = params
    @persist_status = :new
    build_new_business_entity
  end

  # TODO: deprecate
  def persist_update!(business_entity)
    return false if business_entity.nil? || @existing_business_entity.nil?
    if duplicate_needed?(business_entity)
      @existing_business_entity.assign_attributes(valid_to: @timestamp)
      save_entities_in_transaction(business_entity)
    else
      @existing_business_entity.assign_attributes(name: business_entity.name)
      @existing_business_entity.save
    end
  end

  def persist!
    case @persist_status
    when :new
      save_new
    end
  end

  private

  def build_new_business_entity
    @new_business_entity = BusinessEntity.new(office: @office,
                                              jurisdiction: @jurisdiction,
                                              name: @new_params[:name],
                                              code: @new_params[:code],
                                              valid_from: @timestamp)
  end

  def save_new
    @new_business_entity.save
  end

  # TODO: deprecate
  def build_business_entity(params)
    BusinessEntity.new(office: @office,
                       jurisdiction: @jurisdiction,
                       name: params[:name],
                       code: params[:code],
                       valid_from: @timestamp)
  end

  def duplicate_needed?(business_entity)
    entities_match?(business_entity) && entities_present_and_codes_match?(business_entity)
  end

  def entities_match?(business_entity)
    business_entity != @existing_business_entity
  end

  def entities_present_and_codes_match?(business_entity)
    (both_entities_present?(business_entity) && codes_match?(business_entity))
  end

  def both_entities_present?(business_entity)
    @existing_business_entity.present? && business_entity.present?
  end

  def codes_match?(business_entity)
    business_entity.code != @existing_business_entity.code
  end

  def save_entities_in_transaction(business_entity)
    ActiveRecord::Base.transaction do
      @existing_business_entity.save
      business_entity.save
    end
  end
end
