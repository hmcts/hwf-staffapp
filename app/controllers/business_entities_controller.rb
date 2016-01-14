# rubocop:disable ClassLength
class BusinessEntitiesController < ApplicationController
  def index
    authorize :business_entity
    office
    list_jurisdictions
  end

  def new
    redirect_to office_business_entities_path unless jurisdiction
    office
    @business_entity = BusinessEntity.new
    authorize @business_entity
  end

  def create
    @business_entity = BusinessEntity.new(add_valid_from_param(Time.zone.now).merge(create_params))
    authorize @business_entity
    if @business_entity.save
      redirect_to office_business_entities_path
    else
      office
      jurisdiction
      render :new
    end
  end

  def create_params
    { office_id: params[:office_id], jurisdiction_id: params[:jurisdiction_id] }
  end

  def edit
    authorize business_entity
    business_entity
    office
  end

  def update
    authorize business_entity
    if business_entity_update
      redirect_to office_business_entities_path
    else
      render :edit
    end
  end

  private

  def office
    @office ||= Office.find(params[:office_id])
  end

  def business_entity
    @business_entity ||= BusinessEntity.find(params[:id])
  end

  def jurisdiction
    if params[:jurisdiction_id].nil?
      flash[:alert] = 'Please select a jurisdiction to add'
      false
    else
      @jurisdiction ||= Jurisdiction.find(params[:jurisdiction_id])
      true
    end
  end

  def business_entity_update
    change_time = Time.zone.now
    new_be = BusinessEntity.new(build_new_params(change_time))
    business_entity.assign_attributes(valid_to: change_time)
    if new_be.valid?
      ActiveRecord::Base.transaction do
        business_entity.save
        new_be.save
        true
      end
    end
  end

  def build_new_params(change_time)
    business_entity.attributes.merge(add_valid_from_param(change_time))
  end

  def add_valid_from_param(change_time)
    business_entity_params.merge(id: nil, valid_from: change_time)
  end

  def list_jurisdictions
    @jurisdictions = Jurisdiction.joins(join(@office.id)).order(order_sequence).pluck(return_fields)
  end

  def order_sequence
    'business_entities.code IS NOT NULL DESC, jurisdictions.id'
  end

  def join(office_id)
    <<-JOIN
      LEFT OUTER JOIN business_entities
        ON business_entities.jurisdiction_id = jurisdictions.id
        AND business_entities.office_id = #{office_id}
        AND business_entities.valid_to IS NULL
      LEFT OUTER JOIN office_jurisdictions
        ON business_entities.jurisdiction_id = office_jurisdictions.jurisdiction_id
          AND business_entities.office_id = office_jurisdictions.office_id
          AND business_entities.valid_to IS NULL
    JOIN
  end

  def return_fields
    [
      'jurisdictions.id',
      'jurisdictions.name',
      'business_entities.id',
      'business_entities.code',
      'business_entities.name',
      "CASE WHEN office_jurisdictions.office_id IS NULL THEN 'delete'
       ELSE CASE WHEN business_entities.code IS NOT NULL THEN 'edit' ELSE 'new' END
       END AS state"
    ].join(',')
  end

  def business_entity_params
    params.require(:business_entity).permit(:name, :code)
  end
end
