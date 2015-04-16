class ChartsController < ApplicationController
  def dwp_results
    render json: DwpCheck.group(:dwp_result).order('length(dwp_result)').count
  end

  def dwp_results_last_week
    render json: DwpCheck.
      group(:dwp_result).
      group_by_day(:created_at, format: "%d %b %y").
      where('created_at > ?', (Date.today.-6.days)).
      order('length(dwp_result)').
      count
  end
end
