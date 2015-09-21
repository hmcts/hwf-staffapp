class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :load_dwp_data, only: [:index], if: 'user_signed_in? && current_user.manager?'
  before_action :load_graph_data, only: [:index], if: 'user_signed_in? && current_user.admin?'

  def index
    out_of_the_box_redirect
  end

  private

  def load_dwp_data
    @dwpchecks = DwpCheck.
                 by_office(current_user.office_id).
                 page(params[:page]).
                 order('created_at DESC')
  end

  def load_graph_data
    @report_data = []
    Office.non_digital.each do |office|
      @report_data << {
        name: office.name,
        dwp_checks: DwpCheck.by_office_grouped_by_type(office.id).checks_by_day
      }
    end
  end

  def out_of_the_box_redirect
    manager_setup = ManagerSetup.new(current_user)
    redirect_to(edit_office_path(current_user.office)) if manager_setup.setup_office?
  end
end
