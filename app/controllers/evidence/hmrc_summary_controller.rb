module Evidence
  class HmrcSummaryController < ApplicationController
    before_action :authorize_access

    def show
      @form = Forms::Evidence::HmrcCheck.new(hmrc_check)

      render :show
    end

    def complete
      ResolverService.new(evidence, current_user).complete

      # process_evidence_check_flag
      redirect_to confirmation_evidence_path(evidence)
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
  end
end
