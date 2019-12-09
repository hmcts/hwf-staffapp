module ProcessedViewsHelper
  def assign_views
    @application = application
    @applicant = Views::Overview::Applicant.new(application)
    @details = Views::Overview::Details.new(application)
    @application_view = Views::Overview::Application.new(application)
    @result = Views::ApplicationResult.new(application)
    @processing_details = Views::ProcessedData.new(application)
  end

  def paginate(query)
    if per_page_is_all?
      query
    else
      query.paginate(page: page, per_page: per_page)
    end
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
