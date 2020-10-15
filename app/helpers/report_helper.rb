module ReportHelper
  def income_claims_courts
    codes = Views::Reports::IncomeClaimsDataExport::ENTITY_CODES
    Office.where(entity_code: codes).order(name: 'ASC')
  end
end
