module Applications
  class ProcessController < ApplicationController
    before_action :authorize_application_update, except: :create
    before_action :track_application, only: [:index, :edit, :show]
    before_action :check_completed_redirect, except: [:create]

    def create
      application = ApplicationBuilder.new(current_user).build
      authorize application

      application.save
      redirect_to application_personal_informations_path(application)
    end

    private

    def track_application
      event = GtmOnRails::DataLayer::Event.new(
          'Application tracking',
          medium:           application.medium || 'TBC',
          type:             application.application_type || 'TBC',
          office_id:        current_user.office.id,
          jurisdiction_id:  application.detail.jurisdiction_id || 'TBC',
          rails_controller: controller_name,
          rails_action:     action_name
        )
      data_layer.push(event)
    end

    def authorize_application_update
      authorize application, :update?
    end

    def check_completed_redirect
      set_cache_headers
      unless application.created?
        redirect_data = CompletedApplicationRedirect.new(application)
        flash[:alert] = redirect_data.flash_message
        redirect_to redirect_data.path
      end
    end

    def form_params(type)
      class_name = "Forms::Application::#{type.to_s.classify}".constantize
      params.require(:application).permit(*class_name.permitted_attributes.keys)
    end

    def application
      @application ||= Application.find(params[:application_id])
    end

  end
end
