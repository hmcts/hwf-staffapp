module Query
  class LastDwpFailedApplications
    def initialize(user)
      @user = user
    end

    def find
      if @user.admin?
        dwp_faild_for_admin
      else
        applications = @user.office.applications.where(benefits: true, state: 0).
                       where('applications.created_at between ? AND ?', 3.months.ago, Time.zone.now)
        apps_with_failed_checks(applications)
      end
    end

    private

    def apps_with_failed_checks(applications)
      applications.to_a.select do |application|
        benefit_check = application.benefit_checks.last
        next if benefit_check.blank?

        benefit_check.dwp_result == 'BadRequest' && benefit_check.error_message == 'LSCBC959: Service unavailable.'
      end
    end

    def dwp_faild_for_admin
      Application.joins(:benefit_checks).
        where('applications.created_at between ? AND ? AND applications.state = ?', 3.months.ago, Time.zone.now, 0).
        where('benefit_checks.dwp_result = ? AND benefit_checks.error_message = ?',
              'BadRequest', 'LSCBC959: Service unavailable.')
    end
  end
end
