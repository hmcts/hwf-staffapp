module ProcessedViewsHelper
  def assign_views
    @application = application
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
    @summary = Views::ProcessedData.new(application)
  end

  def previous_page
    page - 1 if page > 1
  end

  def next_page
    page + 1 if page < total_pages
  end

  def page
    params[:page].try(:to_i) || 1
  end

  def total_pages
    @paginate.total_pages
  end
end
