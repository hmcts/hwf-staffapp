module FilterApplicationHelper
  def filter
    return {} unless params['filter_applications']
    params.require(:filter_applications).permit(:jurisdiction_id).to_h
  end

  def sort
    return {} unless params['filter_applications']
    params.require(:filter_applications).permit(:order_choice, :sort_by, :sort_to).to_h
  end
end
