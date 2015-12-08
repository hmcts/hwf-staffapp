module ProcessedViewsHelper
  def assign_views
    @application = application
    @processed = Views::ProcessingDetails.new(application)
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end
end
