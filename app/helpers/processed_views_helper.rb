module ProcessedViewsHelper
  def assign_views
    @application = application
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
    @summary = Views::ProcessedData.new(application)
  end
end
