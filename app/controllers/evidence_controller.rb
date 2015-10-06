class EvidenceController < ApplicationController
  def show
    build_overview
  end

  private

  def build_overview
    evidence ||= EvidenceCheck.find(params[:id])
    @overview = Evidence::Views::Overview.new(evidence)
  end
end
