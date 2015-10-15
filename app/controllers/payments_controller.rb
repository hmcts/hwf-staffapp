class PaymentsController < ApplicationController
  def show
    @processing_details = Views::ProcessingDetails.new(payment)
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end

  private

  def payment
    @payment ||= Payment.find(params[:id])
  end

  def application
    payment.application
  end
end
