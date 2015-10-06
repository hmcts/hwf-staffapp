class EvidenceController < ApplicationController
  def show
    get_evidence
  end

  private

  def get_evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end
end
