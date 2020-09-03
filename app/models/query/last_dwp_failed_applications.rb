module Query
  class LastDwpFailedApplications
    def initialize(user)
      @user = user
    end

    def find
      applications = @user.office.applications.where(benefits: true, state: 0).
                     where('applications.created_at between ? AND ?', 3.months.ago, Time.zone.now)
      apps_with_failed_checks(applications)
    end

    private

    def apps_with_failed_checks(applications)
      applications.to_a.select do |application|
        benefit_check = application.benefit_checks.last
        next if benefit_check.blank?

        benefit_check.dwp_result == 'BadRequest' && benefit_check.error_message == 'LSCBC959: Service unavailable.'
      end
    end
  end
end
