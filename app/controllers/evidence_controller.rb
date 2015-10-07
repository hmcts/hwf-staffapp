class EvidenceController < ApplicationController
  def show
    build_overview
  end

  def accuracy
    accuracy_form
  end

  def accuracy_save
    redirect_to evidence_show_path
  end

  private

  def build_overview
    evidence ||= EvidenceCheck.find(params[:id])
    @overview = Evidence::Views::Overview.new(evidence)
  end

  def accuracy_form
    @form = Evidence::Forms::Evidence.new({})
  end
end
