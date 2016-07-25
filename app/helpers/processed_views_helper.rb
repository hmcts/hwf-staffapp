module ProcessedViewsHelper
  def assign_views
    @application = application
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
    @summary = Views::ProcessedData.new(application)
  end

  def paginate(query)
    per_page_count = per_page_is_all? ? 1000000000 : per_page
    query.paginate(page: page, per_page: per_page_count)
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
    per_page_is_all? ? 1 : @paginate.total_pages
  end

  def per_page
    params[:per_page].try(:to_i) || Settings.processed_deleted.per_page
  end

  private

  def per_page_is_all?
    params[:per_page].eql?('All')
  end
end
