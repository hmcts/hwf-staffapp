class BusinessEntitiesController < ApplicationController
  def index
    authorize :business_entity
    @jurisdictions = Query::BusinessEntityManagement.new(office).jurisdictions
  end

  def new
    redirect_to office_business_entities_path if valid_business_entity || !jurisdiction
    @business_entity = BusinessEntity.new
    authorize @business_entity
  end

  def create
    authorize business_entity_service.build_new(business_entity_params)
    if business_entity_service.persist!
      redirect_to office_business_entities_path
    else
      render :new
    end
  end

  def edit
    authorize business_entity
  end

  def update
    authorize business_entity_service.build_update(business_entity_params)

    if business_entity_service.persist!
      redirect_to office_business_entities_path
    else
      render :edit
    end
  end

  private

  helper_method def office
    @office ||= Office.find(params[:office_id])
  end

  helper_method def business_entity
    @business_entity ||= BusinessEntity.find(params[:id])
  end

  def valid_business_entity
    BusinessEntity.current_for(office, jurisdiction).tap do |business_entity|
      flash[:alert] = t('error_messages.create_be_exists',
        jurisdiction: business_entity.jurisdiction.name,
        office: business_entity.office.name) if business_entity
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
    params.require(:business_entity).permit(:name, :code)
  end
end
