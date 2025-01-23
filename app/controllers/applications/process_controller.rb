module Applications
  class ProcessController < ApplicationController
    before_action :authorize_application_update, except: :create
    before_action only: [:index, :edit, :show] do
      track_application(application, 'TBC')
    end
    before_action :check_completed_redirect, except: [:create]
    before_action :store_path, except: [:create]

    def create
      @application = ApplicationBuilder.new(current_user).build
      authorize @application

      @application.save
      redirect_to first_page
    end

    private

    def first_page
      if FeatureSwitching.active?(:band_calculation)
        application_fee_status_path(@application)
      else
        application_personal_informations_path(@application)
      end
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
      params.require(:application).permit(*class_name.permitted_attributes.keys).to_h
    rescue ActionController::ParameterMissing
      {}
    end

    def application
      @application ||= Application.find(params[:application_id])
    end

    def ucd_changes_apply?
      FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
    end
  end
end
