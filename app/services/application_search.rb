class ApplicationSearch
  include Rails.application.routes.url_helpers
  attr_reader :error_message, :results

  def initialize(query, current_user)
    @query = query
    @current_user = current_user
  end

  def online
    return if !prepare_reference! || application_exists_and_user_can_access ||
              application_exists_and_user_cannot_access || online_application_income_invalid?

    if online_application_exists
      edit_online_application_path(@online_application)
    else
      set_error_and_return_nil(:not_found)
    end
  end

  def completed
    if @query.blank?
      return set_error_and_return_nil(:search_blank)
    end

    @results = search_query
    return set_error_and_return_nil(:search_not_found, search_query: @query) if @results.blank?
    @results
  end

  def paginate_search_results(params)
    @sort_by = params[:sort_by]
    @sort_to = params[:sort_to]

    @results = paginate_results(params[:page])
    @results.reorder(sort_results)
  end

  private

  def search_query
    Application.extended_search(@query).
      except_created.
      given_office_only(@current_user.office_id)
  end

  def prepare_reference!
    if @query.present?
      reference = @query.upcase
      reference.gsub!('HWF', '')
      reference.gsub!(/[- ]/, '')
      @query = "HWF-#{reference.scan(/.{1,3}/).join('-')}"
    end
  end

  def application_exists_and_user_can_access
    if application_exists && user_can_access
      redirect_data = CompletedApplicationRedirect.new(@application)
      @error_message = I18n.t(:processed_html, scope: scope, application_path: redirect_data.path)
    end
  end

  def application_exists_and_user_cannot_access
    if application_exists && !user_can_access
      @error_message = I18n.t(:processed_by, scope: scope, office_name: application_office)
    end
  end

  def application_exists
    @application ||= Application.find_by(reference: @query.upcase)
  end

  def user_can_access
    Pundit.policy(@current_user, @application).show?
  end

  def online_application_exists
    @online_application ||= OnlineApplication.find_by(reference: @query.upcase)
  end

  def online_application_income_invalid?
    if online_application_exists && income_required_but_missing
      @error_message = I18n.t(:income_error, scope: scope)
    end
  end

  def income_required_but_missing
    online_application_income_required? && online_application_income_missing?
  end

  def online_application_income_required?
    @online_application.benefits.eql?(false)
  end

  def online_application_income_missing?
    [
      @online_application.income,
      @online_application.income_min_threshold_exceeded,
      @online_application.income_max_threshold_exceeded
    ].all?(&:nil?)
  end

  def scope
    'activemodel.errors.models.forms/search.attributes.reference'
  end

  def application_office
    @application.office.name
  end

  def set_error_and_return_nil(i18n_key, i18n_params = {})
    @error_message = I18n.t(i18n_key, { scope: scope }.merge(i18n_params))
    nil
  end

  def paginate_results(page)
    results.paginate(page: page).
      # There is a bug when you try to order by assocations, this is a fix for it
      joins('LEFT JOIN applicants on applications.id = applicants.application_id').
      joins('LEFT JOIN details on applications.id = details.application_id')
  end

  def sort_results
    default_sort = ['applications.created_at DESC']
    if @sort_by != 'first_name'
      default_sort << 'applicants.first_name ASC'
    end
    if @sort_by != 'last_name'
      default_sort << 'applicants.last_name ASC'
    end

    default_sort.unshift(new_sort_param) if @sort_by.present?
    default_sort.join(', ')
  end

  def new_sort_param
    case @sort_by
    when 'reference'
      "applications.reference #{@sort_to}"
    when 'entered'
      "applications.created_at #{@sort_to}"
    when 'first_name'
      "applicants.first_name #{@sort_to}"
    when 'last_name'
      "applicants.last_name #{@sort_to}"
    when 'case_number'
      "details.case_number #{@sort_to}"
    when 'fee'
      "details.fee #{@sort_to}"
    when 'remission'
      "applications.decision_cost #{@sort_to}"
    when 'completed'
      "applications.decision_date #{@sort_to}"
    end
  end
end
