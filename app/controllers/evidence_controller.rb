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
    redirect_to evidence_show_path
  end

  private

  def prepare_evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end

  def evidence_overview
    prepare_evidence
    @overview = Evidence::Views::Overview.new(@evidence)
  end

  def accuracy_form
    @form = Evidence::Forms::Evidence.new({})
  end

  def save_accuracy_form
    evidence_params = { id: params['id'],
                        correct: params['evidence']['correct'],
                        reason: params['evidence']['reason'] }

    @form = Evidence::Forms::Evidence.new(evidence_params)

    if @form.save
      redirect_to evidence_income_path
    else
      render :accuracy
    end
  end

  def income_form
    @form = Evidence::Forms::Income.new({})
  end

  # TODO: permitted params setup
end
