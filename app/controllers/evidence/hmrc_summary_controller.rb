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
      complete_view_load
      render 'applications/process/confirmation/index'
    rescue ResolverService::UndefinedOutcome
      @hmrc_check = evidence.hmrc_check
      @application_view = Views::Overview::Application.new(evidence.application)
      flash.now[:alert] = I18n.t('hmrc_summary.alert')
      render 'evidence/hmrc_summary/show'
    end

    private

    def complete_view_load
      @application = evidence.application
      process_evidence_check_flag
      @confirm = Views::Confirmation::Result.new(@application)
      @form = Forms::Application::DecisionOverride.new(@application)
    end

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
