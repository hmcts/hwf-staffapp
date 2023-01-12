module Query
  class LastDwpFailedApplications
    def initialize(user)
      @user = user
    end

    def find
      if @user.admin?
        unprocessed_failed_checks(:dwp_faild_for_admin)
      else
        unprocessed_failed_checks(:failed_checks)
      end
    end

    private

    def unprocessed_failed_checks(checks_method)
      method(checks_method).call.map(&:applicationable).select do |application|
        (application.is_a?(Application) && application.state == 'created') || application.is_a?(OnlineApplication)
      end
    end

    def failed_checks
      BenefitCheck.where(dwp_result: 'BadRequest', user_id: office_users).
        where('benefit_checks.created_at between ? AND ?', 3.months.ago, Time.zone.now).
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%').
        select('distinct on (applicationable_id, applicationable_type) *').
        order(:applicationable_id)
    end

    def dwp_faild_for_admin
      BenefitCheck.where(dwp_result: 'BadRequest').
        where('benefit_checks.created_at between ? AND ?', 3.months.ago, Time.zone.now).
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%').
        select('distinct on (applicationable_id, applicationable_type) *').
        order(:applicationable_id)
    end

    def office_users
      @user.office.users.ids
    end
  end
end
