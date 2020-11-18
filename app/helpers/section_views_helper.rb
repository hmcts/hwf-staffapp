module SectionViewsHelper
  def build_sections
    build_from = defined?(application) ? application : online_application
    @applicant = Views::Overview::Applicant.new(build_from)
    @application_view = Views::Overview::Application.new(build_from)
    @details = Views::Overview::Details.new(build_from)
  end
end
