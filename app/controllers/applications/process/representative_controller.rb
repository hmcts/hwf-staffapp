module Applications
  module Process
    class RepresentativeController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Representative.new(representative)
        render :index
      end

      def create
        @form = Forms::Application::Representative.new(representative)
        @form.update(form_params(:representative))

        if @form.save
          redirect_to application_summary_path(application)
        else
          render :index
        end
      end

      private

      def representative
        @representative ||= Representative.find_or_initialize_by(application: application)
      end

    end
  end
end
