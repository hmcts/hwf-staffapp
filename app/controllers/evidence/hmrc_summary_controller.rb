module Evidence
  class HmrcSummaryController < ApplicationController
    before_action :hmrc_check, only: [:show]
    before_action :evidence, only: [:show]

    def show
      authorize evidence

      render :show
    end

    private

    def evidence
      @evidence ||= EvidenceCheck.find(params[:evidence_check_id])
    end

    def hmrc_check
      @hmrc_check ||= HmrcCheck.find(params[:id])
    end
  end
end
