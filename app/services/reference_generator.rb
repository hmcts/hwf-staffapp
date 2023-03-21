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
    return last_reference.succ if last_reference
    "#{reference_prefix}#{1.to_s.rjust(6, '0')}"
  end

  def last_reference
    Application.uncached do
      @references = Application.where('reference LIKE ?', "#{reference_prefix}%").pluck(:reference)
    end
    @references.max
  end
end
