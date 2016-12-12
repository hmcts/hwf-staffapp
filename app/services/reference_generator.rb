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
    if use_new_reference_type
      "PA#{Time.zone.now.strftime('%y')}-"
    else
      "#{business_entity.code.strip}-#{Time.zone.now.strftime('%y')}-"
    end
  end

  def reference
    next_sequence = (last_reference.try(:sequence) || 0) + 1
    if use_new_reference_type
      "#{reference_prefix}#{next_sequence.to_s.rjust(6, '0')}"
    else
      "#{reference_prefix}#{next_sequence}"
    end
  end

  def last_reference
    Application.
      select("max(cast(replace(reference,'#{reference_prefix}','') as integer)) AS sequence").
      where('reference LIKE ?', "#{reference_prefix}%").
      take
  end

  def use_new_reference_type
    @use_new_reference_type ||= Time.zone.now >= Time.zone.parse(Settings.reference.date)
  end
end
