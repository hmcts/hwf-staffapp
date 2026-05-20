module BenefitCheckers
  module DwpApiParamFormatter
    private

    def citizen_params(params)
      {
        last_name: params[:surname],
        date_of_birth: format_date(params[:birth_date]),
        nino_fragment: extract_nino_fragment(params[:ni_number])
      }.compact
    end

    def partner_params
      application = @benefit_check.applicationable
      applicant = application.applicant
      {
        first_name: applicant.partner_first_name,
        last_name: applicant.partner_last_name,
        date_of_birth: format_date(applicant.partner_date_of_birth),
        nino_fragment: extract_nino_fragment(applicant.partner_ni_number),
        postcode: postcode_for(application)
      }.compact
    end

    def applicant_extras
      application = @benefit_check&.applicationable
      return {} unless application

      {
        first_name: application.applicant&.first_name,
        postcode: postcode_for(application)
      }.compact_blank
    end

    def format_date(date_string)
      return if date_string.blank?
      return date_string.strftime('%Y-%m-%d') if date_string.is_a?(Date)

      Date.strptime(date_string, '%Y%m%d').strftime('%Y-%m-%d')
    end

    def extract_nino_fragment(nino)
      return if nino.blank?

      nino.gsub(/[A-Za-z]/, '').last(4)
    end

    def transformed_params(params, partner: false)
      return params if partner
      citizen_params(params).merge(applicant_extras)
    end

  end
end
