class EvidenceController < ApplicationController
  before_action :authenticate_user!

  before_action :authorise_evidence_check_update, except: :show

  def show
    authorize evidence

    processing_details
    application_overview
  end

  def accuracy
    @form = Forms::Evidence::Accuracy.new(evidence)
  end

  def accuracy_save
    @form = Forms::Evidence::Accuracy.new(evidence)
    @form.update_attributes(accuracy_params)

    if @form.save
      redirect_after_accuracy_save
    else
      render :accuracy
    end
  end

  def income
    @form = Evidence::Forms::Income.new(evidence)
  end

  def income_save
    @form = Evidence::Forms::Income.new(evidence)
    @form.update_attributes(income_params)

    if @form.save
      redirect_to evidence_result_path
    else
      render :income
    end
  end

  def result
    application_result
  end

  def summary
    evidence_view
    application_overview
    application_result
  end

  def summary_save
    ResolverService.new(evidence, current_user).complete
    redirect_to evidence_confirmation_path
  end

  def confirmation
    evidence_confirmation
  end

  def return_letter
    application_overview
  end

  def return_application
    redirect_to root_path if ResolverService.new(evidence, current_user).return
  end

  private

  def authorise_evidence_check_update
    authorize evidence, :update?
  end

  def evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end

  def processing_details
    @processing_details = Views::ProcessingDetails.new(evidence)
  end

  def application_overview
    @overview = Views::ApplicationOverview.new(evidence.application)
  end

  def evidence_view
    @evidence_view = Evidence::Views::Evidence.new(evidence)
  end

  def accuracy_params
    params.require(:evidence).permit(*Forms::Evidence::Accuracy.permitted_attributes)
  end

  def redirect_after_accuracy_save
    if @form.correct
      redirect_to evidence_income_path
    else
      redirect_to evidence_summary_path
    end
  end

  def income_params
    params.require(:evidence).permit(*Evidence::Forms::Income.permitted_attributes)
  end

  def application_result
    @result = Views::ApplicationResult.new(evidence.application)
  end

  def evidence_confirmation
    @confirmation = evidence
  end
end
