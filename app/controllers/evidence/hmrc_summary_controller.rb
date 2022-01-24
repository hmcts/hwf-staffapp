module Evidence
  class HmrcSummaryController < ApplicationController
    before_action :authorize_access

    def show
      @form = Forms::Evidence::HmrcCheck.new(hmrc_check)
      @application_view = Views::Overview::Application.new(evidence.application)
      render :show
    end

    def complete
      ResolverService.new(evidence, current_user).complete
      @application = evidence.application

      process_evidence_check_flag
      @confirm = Views::Confirmation::Result.new(@application)
      @form = Forms::Application::DecisionOverride.new(@application)
      render 'applications/process/confirmation/index'
    rescue ResolverService::UndefinedOutcome
      load_form
      flash[:alert] = "Undefined evidence check outcome, please contact support"
      render :show
    end

    private

    def evidence
      @evidence ||= EvidenceCheck.find(params[:evidence_check_id])
    end

    def hmrc_check
      @hmrc_check ||= HmrcCheck.find(params[:id])
    end

    def authorize_access
      authorize evidence
    end

    def load_form
      @form = Forms::Evidence::HmrcCheck.new(hmrc_check)
    end

    def process_evidence_check_flag
      flag_service = EvidenceCheckFlaggingService.new(evidence)
      flag_service.process_flag if flag_service.can_be_flagged?
    end

  end
end
