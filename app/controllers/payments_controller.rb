class PaymentsController < ApplicationController
  def show
    @processing_details = Views::ProcessingDetails.new(payment)
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end

  def accuracy
    @form = Forms::Accuracy.new(payment)
  end

  def accuracy_save
    @form = Forms::Accuracy.new(payment)
    @form.update_attributes(accuracy_params)

    if @form.save
      redirect_to(summary_payment_path(payment))
    else
      render :accuracy
    end
  end

  def summary
    @payment = payment
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::Payment::Result.new(payment)
  end

  def summary_save
    payment.update(
      completed_at: Time.zone.now,
      completed_by: current_user
    )

    redirect_to(confirmation_payment_path(payment))
  end

  def confirmation
  end

  private

  def payment
    @payment ||= Payment.find(params[:id])
  end

  def application
    payment.application
  end

  def accuracy_params
    params.require(:payment).permit(*Forms::Accuracy.permitted_attributes)
  end
end
