class ApplicationSearch
  attr_reader :error_message, :results

  SORT_PARAMS = { reference: 'applications.reference', entered: 'applications.created_at',
                  first_name: 'applicants.first_name', last_name: 'applicants.last_name',
                  case_number: 'details.case_number', fee: 'details.fee',
                  remission: 'applications.decision_cost',
                  completed: 'applications.decision_date' }.freeze

  def initialize(query, current_user)
    @query = query
    @current_user = current_user
  end

  def call
    if @query.blank?
      return set_error_and_return_nil(:search_blank)
    end

    @results = search_query
    return nil if error_checker
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
    if reference_number?(@query)
      result = reference_search_query
      processed_by_check(result)
    elsif name_search?(@query)
      name_search_query
    else
      extended_search
    end
  end

  def reference_search_query
    query = Application.where(reference: @query).includes(:applicant, :evidence_check, :detail)
    admin_can_search_all? ? query : query.except_created
  end

  def extended_search
    query = Application.extended_search(@query).includes(:applicant, :evidence_check, :detail)
    apply_admin_filters(query)
  end

  def name_search_query
    query = Application.name_search(@query).includes(:applicant, :evidence_check, :detail)
    apply_admin_filters(query)
  end

  def apply_admin_filters(query)
    query = query.except_created unless admin_can_search_all?
    admin_can_search_all? ? query : query.given_office_only(@current_user.office_id)
  end

  def admin_can_search_all?
    @current_user.admin?
  end

  def name_search?(query)
    /\d/i.match(query).blank?
  end

  def reference_number?(query)
    /(PA\d\d-\d*)|(HWF-\S{3}-\S{3})/i.match(query).present?
  end

  def scope
    'activemodel.errors.models.forms/search.attributes.reference'
  end

  def set_error_and_return_nil(i18n_key, i18n_params = {})
    @error_message = I18n.t(i18n_key, scope: scope, **i18n_params)
    nil
  end

  def error_checker
    if @results.blank?
      set_error_and_return_nil(:search_not_found, search_query: @query)
      return true
    elsif @processed_by.present?
      set_error_and_return_nil(:processed_by, search_query: @query, office_name: @processed_by)
      return true
    end
    false
  end

  def processed_by_check(result)
    if result.present? && !allowed_to_view?(result)
      @processed_by = result.last.office.name
    end
    result
  end

  def allowed_to_view?(result)
    admin_can_search_all? || result.last.office_id == @current_user.office_id
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
    SORT_PARAMS[@sort_by.to_sym] + " #{@sort_to}"
  end
end
