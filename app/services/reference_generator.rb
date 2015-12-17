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
      office: @application.office, jurisdiction: @application.jurisdiction).first
  end

  def reference_prefix
    "#{business_entity.code.strip}-#{Time.zone.now.strftime('%y')}-"
  end

  def reference
    last_application = Application.where('reference LIKE ?', "#{reference_prefix}%").order(:id).last
    last_sequence = if last_application
                      last_application.reference.gsub(reference_prefix, '').to_i
                    else
                      0
                    end

    "#{reference_prefix}#{last_sequence + 1}"
  end
end
