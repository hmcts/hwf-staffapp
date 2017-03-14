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
    "PA#{Time.zone.now.strftime('%y')}-"
  end

  def reference
    next_sequence = (last_reference.try(:sequence) || 0) + 1
    "#{reference_prefix}#{next_sequence.to_s.rjust(6, '0')}"
  end

  def last_reference
    Application.uncached do
      Application.
        select("max(cast(replace(reference,'#{reference_prefix}','') as integer)) AS sequence").
        where('reference LIKE ?', "#{reference_prefix}%").
        take
    end
  end
end
