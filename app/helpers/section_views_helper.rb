module SectionViewsHelper
  def build_sections
    build_from = defined?(application) ? application : online_application
    @applicant = Views::Overview::Applicant.new(build_from)
    @application_view = Views::Overview::Application.new(build_from)
    @details = Views::Overview::Details.new(build_from)
  end

  def display_discretion_block?(form)
    [:date_fee_paid, :discretion_reason, :discretion_manager_name].each do |key|
      return true if form.errors[key].present?
    end
    false
  end
end
