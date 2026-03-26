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

    def format_date(date_string)
      return if date_string.blank?

      Date.strptime(date_string, '%Y%m%d').strftime('%Y-%m-%d')
    end

    def extract_nino_fragment(nino)
      return if nino.blank?

      nino.gsub(/[A-Za-z]/, '').last(4)
    end
  end
end
