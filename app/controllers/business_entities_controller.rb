class BusinessEntitiesController < ApplicationController
  def index
    authorize :business_entity
    @jurisdictions = Jurisdiction.all.map do |jurisdiction|
      Views::OfficeBusinessEntityState.new(office, jurisdiction)
    end
  end

  def new
    redirect_to office_business_entities_path if valid_business_entity || !jurisdiction
    @business_entity = BusinessEntity.new
    authorize @business_entity
  end

  def create
    authorize business_entity_service.build_new(business_entity_params)
    persist_and_redirect(:new)
  end

  def edit
    authorize business_entity
  end

  def update
    authorize business_entity_service.build_update(business_entity_params)
    persist_and_redirect(:edit)
  end

  def deactivate
    authorize business_entity
  end

  def confirm_deactivate
    authorize business_entity_service.build_deactivate
    persist_and_redirect(:confirm_deactivate)
  end

  private

  def persist_and_redirect(fail_route)
    if business_entity_service.persist!
      redirect_to office_business_entities_path
    else
      @business_entity = business_entity_service.business_entity
      render fail_route
    end
  end

  helper_method def office
    @office ||= Office.find(params[:office_id])
  end

  helper_method def business_entity
    @business_entity ||= BusinessEntity.find(params[:id])
  end

  def valid_business_entity
    BusinessEntity.current_for(office, jurisdiction).tap do |business_entity|
      if business_entity
        flash[:alert] = t('error_messages.create_be_exists',
          jurisdiction: business_entity.jurisdiction.name,
          office: business_entity.office.name)
      end
    end
  end

  helper_method def jurisdiction
    jurisdiction_id = find_jurisdiction_id
    Jurisdiction.find(jurisdiction_id) if jurisdiction_id
  end

  def find_jurisdiction_id
    return params[:jurisdiction_id] if params[:jurisdiction_id].present?
    business_entity.jurisdiction_id if params[:id].present?
  end

  def business_entity_service
    @business_entity_service ||= BusinessEntityService.new(office, jurisdiction)
  end

  def business_entity_params
    params.require(:business_entity).permit(:name, :sop_code)
  end
end
