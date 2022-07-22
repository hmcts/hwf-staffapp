module FilterApplicationHelper
  def filter
    return {} unless params['filter_applications']
    params.require(:filter_applications).permit(:jurisdiction_id).to_h
  end
end
