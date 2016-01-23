class BusinessEntityService

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
    if @persist_status.eql?(:update_existing)
      @existing_business_entity.assign_attributes(name: @new_business_entity.name)
      @existing_business_entity
    else
      @existing_business_entity.assign_attributes(valid_to: @timestamp)
      @new_business_entity
    end
  end

  def persist!
    case @persist_status
    when :new
      save_new
    when :update_existing
      save_existing
    when :update_duplicate
      save_both
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

  def save_both
    ActiveRecord::Base.transaction do
      save_existing
      save_new
    end
  end

  def save_new
    @new_business_entity.save
  end

  def save_existing
    @existing_business_entity.save
  end

  def set_update_type
    codes_match? ? :update_existing : :update_duplicate
  end

  def codes_match?
    @new_business_entity.code == @existing_business_entity.code
  end
end
