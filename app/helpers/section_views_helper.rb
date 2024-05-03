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
    @representative = Views::Overview::Representative.new(build_representative(build_from))
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def result_section_list
    list = ['benefits_result', 'savings_result', 'income_result']
    list << 'calculation_scheme' if FeatureSwitching.active?(:band_calculation)
    list
  end

  def build_representative(build_from)
    if ucd_changes_apply?
      Representative.new(
        first_name: build_from.legal_representative_first_name,
        last_name: build_from.legal_representative_last_name,
        organisation: build_from.legal_representative_organisation_name,
        position: build_from.legal_representative_position
      )
    else
      build_from.representative
    end
  end
end
