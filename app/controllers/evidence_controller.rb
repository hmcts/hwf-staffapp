class EvidenceController < ApplicationController
  def show
    evidence_overview
  end

  def accuracy
    accuracy_form
  end

  def accuracy_save
    save_accuracy_form
  end

  def income
    income_form
  end

  def income_save
    income_form_save
  end

  def result
    evidence_result
  end

  def summary
    evidence_view
    evidence_overview
    evidence_result
  end

  def confirmation
    evidence_confirmation
  end

  private

  def evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end

  def evidence_overview
    @overview = Evidence::Views::Overview.new(evidence)
  end

  def evidence_view
    @evidence_view = Evidence::Views::Evidence.new(evidence)
  end

  def accuracy_form
    @form = Evidence::Forms::Evidence.new(accuracy_params)
  end

  def save_accuracy_form
    @form = Evidence::Forms::Evidence.new(accuracy_params_for_save)

    if @form.save
      redirect_after_accuracy_save
    else
      render :accuracy
    end
  end

  def accuracy_params
    { id: evidence.id, correct: evidence.correct, reason: evidence.reason.try(:explanation) }
  end

  def accuracy_params_for_save
    { id: params['id'] }.merge(params.require(:evidence).permit(:correct, :reason).symbolize_keys)
  end

  def redirect_after_accuracy_save
    if @form.correct
      redirect_to evidence_income_path
    else
      redirect_to evidence_summary_path
    end
  end

  def income_form
    @form = Evidence::Forms::Income.new(income_params)
  end

  def income_form_save
    @form = Evidence::Forms::Income.new(income_params_for_save)

    if @form.save
      redirect_to evidence_result_path
    else
      render :income
    end
  end

  def income_params
    { id: evidence.id, amount: evidence.income }
  end

  def income_params_for_save
    { id: params['id'] }.merge(params.require(:evidence).permit(:amount).symbolize_keys)
  end

  def evidence_result
    @result = Evidence::Views::Result.new(evidence)
  end

  def evidence_confirmation
    @confirmation = evidence
  end

  # TODO: permitted params setup
end
