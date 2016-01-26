class BusinessEntitiesController < ApplicationController
  def index
    authorize :business_entity
    list_jurisdictions
  end

  def new
    redirect_to office_business_entities_path if valid_business_entity || !jurisdiction
    @business_entity = BusinessEntity.new
    authorize @business_entity
  end

  def create
    @business_entity = business_entity_service.build(business_entity_params)
    authorize @business_entity
    if @business_entity.save
      redirect_to office_business_entities_path
    else
      render :new
    end
  end

  def edit
    authorize business_entity
  end

  def update
    bes = business_entity_service
    new_be = bes.check_update(business_entity_params)
    authorize new_be

    if bes.persist_update!(new_be)
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
    be = BusinessEntity.find_by(office_id: params[:office_id],
                                jurisdiction_id: params[:jurisdiction_id],
                                valid_to: nil)
    flash[:alert] = t('error_messages.create_be_exists', jurisdiction: be.jurisdiction.name,
                                                         office: be.office.name) if be
    be
  end

  helper_method def jurisdiction
    j_id = find_jurisdiction_id
    return false unless j_id
    @jurisdiction ||= Jurisdiction.find(j_id)
  end

  def find_jurisdiction_id
    return params[:jurisdiction_id] if params[:jurisdiction_id].present?
    return business_entity.jurisdiction_id if params[:id].present?
  end

  def business_entity_service
    jurisdiction
    BusinessEntityService.new(office, @jurisdiction)
  end

  def list_jurisdictions
    @jurisdictions = Jurisdiction.joins(join(office.id)).order(order_sequence).
                     pluck_h(list_fields).each { |j| j[:state] = state(j) }
  end

  def state(j)
    if j['office_jurisdictions.office_id'].present?
      'edit'
    else
      j['business_entities.code'].present? ? 'delete' : 'new'
    end
  end

  def order_sequence
    'business_entities.code IS NOT NULL DESC, jurisdictions.id'
  end

  def join(office_id)
    <<-JOIN
      LEFT OUTER JOIN business_entities ON business_entities.jurisdiction_id = jurisdictions.id
        AND business_entities.office_id = #{office_id} AND business_entities.valid_to IS NULL
      LEFT OUTER JOIN office_jurisdictions
        ON business_entities.jurisdiction_id = office_jurisdictions.jurisdiction_id
          AND business_entities.office_id = office_jurisdictions.office_id
          AND business_entities.valid_to IS NULL
    JOIN
  end

  def list_fields
    ['jurisdictions.id', 'jurisdictions.name', 'business_entities.id',
     'business_entities.code', 'business_entities.name', 'office_jurisdictions.office_id']
  end

  def business_entity_params
    params.require(:business_entity).permit(:name, :code)
  end
end
