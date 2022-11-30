module Query
  class LastDwpFailedApplications
    def initialize(user)
      @user = user
    end

    def find
      if @user.admin?
        dwp_faild_for_admin
      else
        apps_with_failed_checks
      end
    end

    private

    def apps_with_failed_checks
      @user.office.applications.where(benefits: true, state: 0).includes(:benefit_checks).
        where('applications.created_at between ? AND ?', 3.months.ago, Time.zone.now).
        where(benefit_checks: { dwp_result: 'BadRequest' }).
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%')
    end

    def dwp_faild_for_admin
      Application.joins(:benefit_checks).includes(:benefit_checks).distinct.
        where('applications.created_at between ? AND ? AND applications.state = ?', 3.months.ago, Time.zone.now, 0).
        where(benefit_checks: { dwp_result: 'BadRequest' }).
        where('benefit_checks.error_message LIKE ? OR benefit_checks.error_message LIKE ?',
              '%LSCBC%', '%Service unavailable%')
    end
  end
end
