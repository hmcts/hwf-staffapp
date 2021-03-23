module ReportHelper
  def income_claims_courts
    codes = Views::Reports::IncomeClaimsDataExport::ENTITY_CODES
    Office.where(entity_code: codes).order(name: 'ASC')
  end

  def ocmc_courts
    Office.sorted.non_digital
  end
end
