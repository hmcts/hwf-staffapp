class BecImport
  def initialize(lines)
    @lines = lines
  end

  def delete_unused
    BusinessEntity.all.each do |be|
      be.destroy if to_delete?(be)
    end
  end

  def update_existing
    @lines.each do |line|
      update_hash = {}.tap do |h|
        h[:code] = line[:code] if line[:code].present?
        h[:name] = line[:description] if line[:description].present?
      end

      unless update_hash.empty?
        be_from_line(line).update(update_hash)
      end
    end
  end

  private

  def be_from_line(line)
    BusinessEntity.where(office_id: line[:office_id], jurisdiction_id: line[:jurisdiction_id]).first
  end

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
