class BecImport
  def initialize(lines)
    @lines = lines
  end

  def delete_unused
    BusinessEntity.all.each do |be|
      be.destroy if to_delete?(be)
    end
  end

  private

  def to_delete?(be)
    !application_with_be?(be) && !office_with_be?(be) && !line_with_be?(be)
  end

  def application_with_be?(be)
    Application.where(business_entity: be).count > 0
  end

  def office_with_be?(be)
    OfficeJurisdiction.where(office: be.office, jurisdiction: be.jurisdiction).count > 0
  end

  def line_with_be?(be)
    @lines.any? do |line|
      line[:office_id] == be.office_id && line[:jurisdiction_id] == be.jurisdiction_id
    end
  end
end
