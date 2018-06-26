class BusinessEntityService
  attr_reader :business_entity

  def initialize(office, jurisdiction)
    @office = office
    @jurisdiction = jurisdiction
    @timestamp = Time.zone.now
    @existing_business_entity = BusinessEntity.current_for(office, jurisdiction)
  end

  def build_new(params)
    @new_params = params
    @persist_status = :new
    build_new_business_entity
  end

  def build_update(params)
    @new_params = params
    build_new_business_entity
    @persist_status = set_update_type
    @persist_status.eql?(:update_existing) ? update_and_return_existing : update_existing_return_new
  end

  def build_deactivate
    deactivate_existing
    @persist_status = :delete
    @existing_business_entity
  end

  def persist!
    case @persist_status
    when :new
      save_new
    when :update_existing, :delete
      save_existing
    when :update_duplicate
      save_both
    end
    any_errors?
  end

  private

  def build_new_business_entity
    @new_business_entity = BusinessEntity.new(office: @office,
                                              jurisdiction: @jurisdiction,
                                              name: @new_params[:name],
                                              sop_code: @new_params[:sop_code],
                                              valid_from: @timestamp)
  end

  def update_and_return_existing
    @existing_business_entity.assign_attributes(name: @new_business_entity.name)
    @existing_business_entity
  end

  def update_existing_return_new
    @existing_business_entity.assign_attributes(valid_to: @timestamp)
    @new_business_entity
  end

  def save_both
    ActiveRecord::Base.transaction do
      save_existing
      save_new
    end
  end

  def save_new
    @new_business_entity.save
    @business_entity = @new_business_entity
  end

  def save_existing
    @existing_business_entity.save
    @business_entity = @existing_business_entity
  end

  def set_update_type
    codes_match? ? :update_existing : :update_duplicate
  end

  def codes_match?
    @new_business_entity.code == @existing_business_entity.code
  end

  def deactivate_existing
    @existing_business_entity.assign_attributes(valid_to: @timestamp)
  end

  def any_errors?
    @business_entity.try(:errors).blank?
  end
end
