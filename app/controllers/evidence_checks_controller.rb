class EvidenceChecksController < ApplicationController
  include FilterApplicationHelper
  include ProcessedViewsHelper

  skip_after_action :verify_authorized, only: :index

  def index
    waiting_for_evidence = LoadApplications.waiting_for_evidence(current_user, filter, order,
                                                                 show_form_name, show_court_fee)
    @paginate = paginate(waiting_for_evidence)
    @waiting_for_evidence = @paginate.map do |application|
      Views::ApplicationList.new(application.evidence_check)
    end
    @show_form_name = show_form_name
    @show_court_fee = show_court_fee
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
