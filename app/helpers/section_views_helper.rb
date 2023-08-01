module SectionViewsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def build_sections
    build_from = defined?(application) ? application : online_application
    @applicant = Views::Overview::Applicant.new(build_from)
    @application_view = Views::Overview::Application.new(build_from)
    @details = Views::Overview::Details.new(build_from)
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def result_section_list
    list = ['benefits_result', 'savings_result', 'income_result']
    list << 'calculation_scheme' if FeatureSwitching.active?(:band_calculation)
    list
  end
end
