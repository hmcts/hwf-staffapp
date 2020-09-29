module ReportHelper
  def analytic_service_courts
    codes = Views::Reports::AnalyticServicesDataExport::ENTITY_CODES
    Office.where(entity_code: codes)
  end
end
