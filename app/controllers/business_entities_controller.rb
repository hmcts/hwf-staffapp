class BusinessEntitiesController < ApplicationController

  def index
    authorize :business_entity
    office
    list_jurisdictions
  end

  def new
    @business_entity = BusinessEntity.new
    authorize @business_entity
  end

  def edit
    authorize business_entity
    business_entity
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
    business_entity.attributes.merge(business_entity_params.merge(id: nil, valid_from: change_time))
  end

  def list_jurisdictions
    @jurisdictions = Jurisdiction.joins(join_command).order(order_sequence).pluck(return_fields)
  end

  def order_sequence
    'business_entities.code IS NOT NULL DESC, jurisdictions.id'
  end

  def join_command
    <<-JOIN
      LEFT OUTER JOIN business_entities
        ON business_entities.jurisdiction_id = jurisdictions.id
        AND business_entities.office_id = 1
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
      "CASE WHEN office_jurisdictions.office_id IS NOT NULL THEN NULL
       ELSE CASE WHEN business_entities.code IS NOT NULL THEN 'edit' ELSE 'new' END
       END AS state"
    ].join(',')
  end

  def business_entity_params
    params.require(:business_entity).permit(:name, :code)
  end
end
