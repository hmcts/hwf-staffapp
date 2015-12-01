class EvidenceChecksController < ApplicationController
  before_action :authenticate_user!

  def show
    @application = evidence_check.application
    @confirm = Views::Confirmation::Result.new(@application)
  end

  private

  def evidence_check
    @evidence_check ||= EvidenceCheck.find(params[:id])
  end

  def render_not_found
    render nothing: true, status: 404
  end
end
