class ReferenceGenerator
  def initialize(application)
    @application = application
  end

  def attributes
    { reference: reference }
  end

  private

  def business_entity
    @business_entity ||=
      BusinessEntity.current_for(@application.office, @application.detail.jurisdiction)
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
