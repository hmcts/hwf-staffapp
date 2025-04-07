module FilterApplicationHelper
  def filter
    return {} unless params['filter_applications']
    params.require(:filter_applications).permit(:jurisdiction_id).to_h
  end

  def show_form_name
    return false unless params['filter_applications']
    params.require(:filter_applications).permit(:application_details).to_h["application_details"] == "form_name"
  end

  def show_court_fee
    return false unless params['filter_applications']
    params.require(:filter_applications).permit(:application_details).to_h["application_details"] == "court_fee"
  end

  def order
    return :desc unless params['filter_applications']
    params.require(:filter_applications).permit(:order_choice).to_h
  end
end
