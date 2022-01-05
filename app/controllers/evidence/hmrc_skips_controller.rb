module Evidence
  class HmrcSkipsController < ApplicationController

    def update
      authorize evidence, :update?

      if @evidence.update(income_check_type: 'paper')
        redirect_to evidence_check_path(@evidence)
      else
        redirect_to new_evidence_check_hmrc_path(@evidence)
      end
    end

    private

    def evidence
      @evidence ||= EvidenceCheck.find(params[:evidence_check_id])
    end
  end
end
