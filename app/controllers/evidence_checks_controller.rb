class EvidenceChecksController < ApplicationController
  def show
    authorize evidence_check

    @application = evidence_check.application

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           @application.medium || 'TBC',
        type:             @application.application_type || 'TBC',
        office_id:        current_user.office.id,
        jurisdiction_id:  @application.detail.jurisdiction_id || 'TBC',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)

    @confirm = Views::Confirmation::Result.new(@application)
  end

  private

  def evidence_check
    @evidence_check ||= EvidenceCheck.find(params[:id])
  end
end
