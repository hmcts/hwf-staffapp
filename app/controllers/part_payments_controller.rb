class PartPaymentsController < ApplicationController
  before_action :authorize_part_payment_update, except: :show

  include SectionViewsHelper

  def show
    authorize part_payment

    processing_details
    build_sections

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def accuracy
    @form = Forms::PartPayment::Accuracy.new(part_payment)

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def accuracy_save
    @form = Forms::PartPayment::Accuracy.new(part_payment)
    @form.update_attributes(accuracy_params)

    if @form.save
      redirect_to(summary_part_payment_path(part_payment))
    else
      render :accuracy
    end
  end

  def summary
    @part_payment = part_payment
    build_sections
    @result = Views::PartPayment::Result.new(part_payment)

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def summary_save
    ResolverService.new(part_payment, current_user).complete
    redirect_to(confirmation_part_payment_path(part_payment))
  end

  def confirmation
    build_sections
    @result = Views::PartPayment::Result.new(part_payment)

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def return_letter
    build_sections

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def return_application
    if ResolverService.new(part_payment, current_user).return
      redirect_to root_path
    else
      flash[:alert] = t('error_messages.part_payment.cannot_be_saved')
      redirect_to return_letter_part_payment_path
    end
  end

  private

  def part_payment
    @part_payment ||= PartPayment.find(params[:id])
  end

  def application
    part_payment.application
  end

  def authorize_part_payment_update
    authorize part_payment, :update?
  end

  def processing_details
    @processing_details = Views::ProcessedData.new(part_payment.application)
  end

  def accuracy_params
    params.require(:part_payment).permit(*Forms::Accuracy.permitted_attributes)
  end
end
