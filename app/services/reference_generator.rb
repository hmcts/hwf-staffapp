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
    return last_reference.try(:reference).succ if last_reference.try(:reference)
    "#{reference_prefix}#{1.to_s.rjust(6, '0')}"
  end

  def last_reference
    Application.uncached do
      Application.where('reference LIKE ?', "#{reference_prefix}%").last
    end
  end
end
