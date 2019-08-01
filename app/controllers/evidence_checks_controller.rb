class EvidenceChecksController < ApplicationController
  skip_after_action :verify_authorized, only: :index

  def index
    @waiting_for_evidence = LoadApplications.waiting_for_evidence(current_user)
  end

  def show
    authorize evidence_check

    @application = evidence_check.application

    track_application(@application, 'TBC')

    @confirm = Views::Confirmation::Result.new(@application)
  end

  private

  def evidence_check
    @evidence_check ||= EvidenceCheck.find(params[:id])
  end
end
