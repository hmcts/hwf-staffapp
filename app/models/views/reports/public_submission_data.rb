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

      def submission_total_time_taken
        @applications.
          joins(:online_application).
          group('offices.name').
          pluck(
            :name,
            'cast(AVG(applications.completed_at-online_applications.created_at) as text)'
          )
      end

      def submission_seven_day_time_taken
        @applications.
          joins(:online_application).
          where('applications.created_at > ?', (Time.zone.today.-6.days)).
          group('offices.name').
          pluck(
            :name,
            'cast(AVG(applications.completed_at-online_applications.created_at) as text)'
          )
      end
    end
  end
end
