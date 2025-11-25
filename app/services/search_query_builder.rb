module SearchQueryBuilder
  extend ActiveSupport::Concern

  private

  def build_reference_sql
    state_condition = admin_can_search_all? ? '' : 'AND applications.state != 0'

    <<~SQL.squish
      SELECT DISTINCT applications.*
      FROM applications
      WHERE applications.reference = #{sanitize(@query)}
        #{state_condition}
        AND (applications.purged IS NULL OR applications.purged = FALSE)
      ORDER BY applications.created_at DESC
    SQL
  end

  # rubocop:disable Metrics/MethodLength
  def build_extended_search_sql
    state_condition = admin_can_search_all? ? '' : 'AND applications.state != 0'
    office_condition = admin_can_search_all? ? '' : "AND applications.office_id = #{@current_user.office_id}"
    search_term = sanitize("%#{@query}%")

    <<~SQL.squish
      SELECT DISTINCT applications.*
      FROM applications
      LEFT JOIN details ON details.application_id = applications.id
      LEFT JOIN applicants ON applicants.application_id = applications.id
      WHERE (
        applications.reference ILIKE #{search_term}
        OR details.case_number ILIKE #{search_term}
        OR applicants.ni_number ILIKE #{search_term}
      )
      #{state_condition}
      #{office_condition}
      AND (applications.purged IS NULL OR applications.purged = FALSE)
      ORDER BY applications.created_at DESC
    SQL
  end

  def build_name_search_sql
    state_condition = admin_can_search_all? ? '' : 'AND applications.state != 0'
    office_condition = admin_can_search_all? ? '' : "AND applications.office_id = #{@current_user.office_id}"
    search_term = sanitize("%#{@query}%")

    <<~SQL.squish
      SELECT DISTINCT applications.*
      FROM applications
      INNER JOIN applicants ON applicants.application_id = applications.id
      WHERE (
        applicants.first_name ILIKE #{search_term}
        OR applicants.last_name ILIKE #{search_term}
        OR CONCAT(applicants.first_name, ' ', applicants.last_name) ILIKE #{search_term}
      )
      #{state_condition}
      #{office_condition}
      AND (applications.purged IS NULL OR applications.purged = FALSE)
      ORDER BY applications.created_at DESC
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def execute_search_query(sql)
    application_ids = ActiveRecord::Base.connection.execute(sql).pluck('id')
    return [] if application_ids.empty?

    Application.where(id: application_ids).
      includes(:applicant, :evidence_check, :detail).
      order(created_at: :desc)
  end

  def sanitize(value)
    ActiveRecord::Base.connection.quote(value)
  end

  def admin_can_search_all?
    @current_user.admin?
  end
end
