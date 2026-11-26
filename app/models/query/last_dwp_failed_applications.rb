module Query
  class LastDwpFailedApplications
    def initialize(user)
      @user = user
    end

    def find
      if @user.admin?
        unprocessed_failed_checks(:dwp_failed_for_admin)
      else
        unprocessed_failed_checks(:failed_checks)
      end
    end

    private

    def unprocessed_failed_checks(checks_method)
      applications = method(checks_method).call.map(&:applicationable)
      linked_applications = linked_applications_by_reference(applications)

      applications.select do |application|
        if application.is_a?(Application)
          application.state == 'created'
        else
          unprocessed_application?(linked_applications[application.reference])
        end
      end.sort_by(&:updated_at).reverse
    end

    # Loads, in a single query, the paper application linked by reference to each
    # online application, so the select above does not run one query per row.
    def linked_applications_by_reference(applications)
      # rubocop:disable Style/SelectByKind
      online_applications = applications.select { |application| application.is_a?(OnlineApplication) }
      # rubocop:enable Style/SelectByKind
      references = online_applications.filter_map(&:reference)
      return {} if references.empty?

      # order(:id) so index_by keeps the highest-id row per reference (matching
      # the previous `where(reference:).last`).
      Application.where(reference: references).order(:id).index_by(&:reference)
    end

    def unprocessed_application?(linked_application)
      linked_application.blank? || linked_application.state == 'created'
    end

    def failed_checks
      list = all_failed_checks.where(benefit_checks: { user_id: office_users })
      list.select('distinct on (applicationable_id, applicationable_type) *').order(:applicationable_id)
    end

    def dwp_failed_for_admin
      all_failed_checks.select('distinct on (applicationable_id, applicationable_type) *').order(:applicationable_id)
    end

    def all_failed_checks
      BenefitCheck.where('benefit_checks.created_at between ? AND ?', 3.months.ago, Time.zone.now).
        merge(unavailable_checks.or(dwp_internal_error_checks)).includes(:applicationable)
    end

    # rubocop:disable Layout/LineLength
    def unavailable_checks
      BenefitCheck.where("dwp_result = 'BadRequest' OR dwp_result = 'Server unavailable'").
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%', '%not available%')
    end
    # rubocop:enable Layout/LineLength

    # DWP error 2000 should be included too
    def dwp_internal_error_checks
      BenefitCheck.where(dwp_result: 'Unspecified error').
        where('benefit_checks.error_message ~ ?', '"code"\\s*:\\s*"2000"')
    end

    def office_users
      @user.office.users.ids
    end
  end
end
