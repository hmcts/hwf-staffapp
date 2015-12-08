class PartPaymentsController < ApplicationController
  def show
    @processing_details = Views::ProcessingDetails.new(part_payment)
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end

  def accuracy
    @form = Forms::PartPayment::Accuracy.new(part_payment)
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
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::PartPayment::Result.new(part_payment)
  end

  def summary_save
    ResolverService.new(part_payment, current_user).complete
    redirect_to(confirmation_part_payment_path(part_payment))
  end

  def confirmation
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::PartPayment::Result.new(part_payment)
  end

  def return_letter
    application_overview
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

  def application_overview
    @overview = Views::ApplicationOverview.new(part_payment.application)
  end

  def accuracy_params
    params.require(:part_payment).permit(*Forms::Accuracy.permitted_attributes)
  end
end
