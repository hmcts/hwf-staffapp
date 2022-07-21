module FilterApplicationHelper
  def filter
    return {} unless params['filter_applications']
    return params.require(:filter_applications).permit(:jurisdiction_id).to_h
  end
end
