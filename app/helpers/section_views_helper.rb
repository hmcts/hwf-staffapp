module SectionViewsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def build_sections
    build_from = defined?(application) ? application : online_application
    @fee_status = Views::Overview::FeeStatus.new(build_from)
    @applicant = Views::Overview::Applicant.new(build_from)
    @online_applicant = Views::Overview::OnlineApplicant.new(build_from)
    @children = Views::Overview::Children.new(build_from)
    @application_view = Views::Overview::Application.new(build_from)
    @details = Views::Overview::Details.new(build_from)
    @declaration = Views::Overview::Declaration.new(build_from)
    @representative = Views::Overview::Representative.new(build_from.representative)
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def result_section_list
    list = ['benefits_result', 'savings_result', 'income_result']
    list << 'calculation_scheme' if FeatureSwitching.active?(:band_calculation)
    list
  end
end
