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
      method(checks_method).call.map(&:applicationable).select do |application|
        if application.is_a?(Application)
          application.state == 'created'
        else
          unprocessed_application?(application.reference)
        end
      end
    end

    def unprocessed_application?(reference)
      linked_application = Application.where(reference: reference).last
      linked_application.blank? || linked_application&.state == 'created'
    end

    def failed_checks
      list = all_failed_checks.where(benefit_checks: { user_id: office_users })
      list.select('distinct on (applicationable_id, applicationable_type) *').order(:applicationable_id)
    end

    def dwp_failed_for_admin
      all_failed_checks.select('distinct on (applicationable_id, applicationable_type) *').order(:applicationable_id)
    end

    # rubocop:disable Layout/LineLength
    def all_failed_checks
      BenefitCheck.where("dwp_result = 'BadRequest' OR dwp_result = 'Server unavailable'").
        where('benefit_checks.created_at between ? AND ?', 3.months.ago, Time.zone.now).
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%', '%not available%').includes(:applicationable)
    end
    # rubocop:enable Layout/LineLength

    def office_users
      @user.office.users.ids
    end
  end
end
