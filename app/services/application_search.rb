class ApplicationSearch
  include Rails.application.routes.url_helpers
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

  def scope
    'activemodel.errors.models.forms/search.attributes.reference'
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
    SORT_PARAMS[@sort_by.to_sym] + " #{@sort_to}"
  end
end
