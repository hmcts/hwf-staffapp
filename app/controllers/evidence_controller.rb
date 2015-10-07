class EvidenceController < ApplicationController
  def show
    evidence_overview
  end

  def accuracy
    accuracy_form
  end

  def accuracy_save
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
end
