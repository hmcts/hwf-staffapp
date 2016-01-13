class ReferenceGenerator
  def initialize(application)
    @application = application
  end

  def attributes
    {
      business_entity: business_entity,
      reference: reference
    }
  end

  private

  def business_entity
    @business_entity ||= BusinessEntity.where(
      office: @application.office, jurisdiction: @application.jurisdiction, valid_to: nil).first
  end

  def reference_prefix
    "#{business_entity.code.strip}-#{Time.zone.now.strftime('%y')}-"
  end

  def reference
    last_sequence = last_reference.try(:sequence) || 0

    "#{reference_prefix}#{last_sequence + 1}"
  end

  def last_reference
    Application.
      select("max(cast(replace(reference,'#{reference_prefix}','') as integer)) AS sequence").
      where('reference LIKE ?', "#{reference_prefix}%").
      take
  end
end
