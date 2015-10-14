class EvidenceController < ApplicationController
  def show
    processing_details
    evidence_overview
  end

  def accuracy
    @form = Evidence::Forms::Accuracy.new(evidence)
  end

  def accuracy_save
    @form = Evidence::Forms::Accuracy.new(evidence)
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
    evidence_result
  end

  def summary
    evidence_view
    evidence_overview
    evidence_result
  end

  def summary_save
    record_confirmation
  end

  def confirmation
    evidence_confirmation
  end

  private

  def evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end

  def processing_details
    @processing_details = Views::Evidence::ProcessingDetails.new(evidence)
  end

  def evidence_overview
    @overview = Evidence::Views::Overview.new(evidence)
  end

  def evidence_view
    @evidence_view = Evidence::Views::Evidence.new(evidence)
  end

  def accuracy_params
    params.require(:evidence).permit(*Evidence::Forms::Accuracy.permitted_attributes)
  end

  def redirect_after_accuracy_save
    if @form.correct
      redirect_to evidence_income_path
    else
      redirect_to evidence_summary_path
    end
  end

  def record_confirmation
    evidence.update(
      completed_at: Time.zone.now,
      completed_by: current_user
    )
    redirect_to evidence_confirmation_path
  end

  def income_params
    params.require(:evidence).permit(*Evidence::Forms::Income.permitted_attributes)
  end

  def evidence_result
    @result = Evidence::Views::Result.new(evidence)
  end

  def evidence_confirmation
    @confirmation = evidence
  end
end
