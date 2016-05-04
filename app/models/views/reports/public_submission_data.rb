module Views
  module Reports
    class PublicSubmissionData

      def initialize
        @applications = Application.joins(:office).where.not(online_application_id: nil)
      end

      def submission_all_time_total
        @applications.count
      end

      def submission_all_time
        @applications.
          group('offices.name').
          order('count_all DESC').
          count
      end

      def submission_seven_day_total
        @applications.
          where('applications.created_at > ?', (Time.zone.today.-6.days)).
          count
      end

      def submission_seven_day
        @applications.
          where('applications.created_at > ?', (Time.zone.today.-6.days)).
          group('offices.name').
          order('count_all DESC').
          count
      end
    end
  end
end
