class IncomeKindRefactorService
  def initialize(application, type)
    @application = application
    @type = type
    @changed = false
  end

  def call
    normalize_partner_roles
    normalize_income_kinds

    @application.save! if @changed
  end

  ALLOWED_NORMALIZED_VALUES = [
    :wage, :net_profit, :child_benefit, :working_credit, :child_credit, :maintenance_payments, :jsa, :esa,
    :universal_credit, :pensions, :rent_from_cohabit, :rent_from_properties, :cash_gifts, :financial_support,
    :loans, :other_income, :none_of_the_above
  ].map(&:to_s).freeze

  INCOME_KIND_MAP = {
    'wages before tax and national insurance are taken off' => 'wage',
    'wages' => 'wage',
    '1' => 'wage',

    'net profits from self employment' => 'net_profit',
    '2' => 'net_profit',

    'child benefit' => 'child_benefit',
    '3' => 'child_benefit',

    'working tax credit' => 'working_credit',
    '4' => 'working_credit',

    'child tax credit' => 'child_credit',
    '5' => 'child_credit',

    'maintenance payments' => 'maintenance_payments',
    '6' => 'maintenance_payments',

    'contribution-based jobseekers allowance (jsa)' => 'jsa',
    '7' => 'jsa',

    'contribution-based employment and support allowance (esa)' => 'esa',
    '8' => 'esa',

    'universal credit' => 'universal_credit',
    '9' => 'universal_credit',

    'pensions (state, work, private, pension credit (savings credit))' => 'pensions',
    'pensions (state, work, private)' => 'pensions',
    'pension credit (savings credit)' => 'pensions',
    '10' => 'pensions',
    '11' => 'pensions',

    'rent from anyone living with the applicant' => 'rent_from_cohabit',
    'rent from anyone living with the partner' => 'rent_from_cohabit',
    'rent from anyone living with you' => 'rent_from_cohabit',
    '12' => 'rent_from_cohabit',
    '14' => 'rent_from_cohabit',

    'rent from other properties the applicant owns' => 'rent_from_properties',
    'rent from other properties the partner owns' => 'rent_from_properties',
    'rent from other properties you own' => 'rent_from_properties',
    '13' => 'rent_from_properties',
    '15' => 'rent_from_properties',

    'cash gifts - include all one off payments' => 'cash_gifts',
    'cash gifts' => 'cash_gifts',
    '16' => 'cash_gifts',

    'financial support from family - include all one off payments' => 'financial_support',
    'financial support from others' => 'financial_support',
    '17' => 'financial_support',

    'loans' => 'loans',
    '18' => 'loans',

    'other income - for example, income from online selling or from dividend or interest payments' => 'other_income',
    'other income - for example, income from online selling' => 'other_income',
    'other income  - for example, income from online selling' => 'other_income',
    'other income' => 'other_income',
    '19' => 'other_income',

    'none of the above' => 'none_of_the_above',
    'no income' => 'none_of_the_above',
    '20' => 'none_of_the_above'
  }.freeze

  private

  def normalize_partner_roles # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    [:applicant, :partner].each do |person|
      next unless @application.income_kind[person].is_a?(Array)

      @application.income_kind[person].map! do |value|
        case value
        when 'Rent from anyone living with the applicant'
          @changed = true
          person == :partner ? 'Rent from anyone living with the partner' : value
        when 'Rent from other properties the applicant owns'
          @changed = true
          person == :partner ? 'Rent from other properties the partner owns' : value
        when 'Rent from anyone living with the partner'
          @changed = true
          person == :applicant ? 'Rent from anyone living with the applicant' : value
        when 'Rent from other properties the partner owns'
          @changed = true
          person == :applicant ? 'Rent from other properties the applicant owns' : value
        else
          value
        end
      end
    end
  end # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize

  def normalize_income_kinds # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    [:applicant, :partner].each do |person|
      next unless @application.income_kind[person].is_a?(Array)

      @application.income_kind[person].each_with_index do |value, index|
        if ALLOWED_NORMALIZED_VALUES.include?(value.to_s)
          next
        end
        normalized = INCOME_KIND_MAP[value.downcase]
        if normalized
          @application.income_kind[person][index] = normalized
          @changed = true
        else
          Sentry.capture_message("No income kind match",
                                 extra: {
                                   application_type: @type,
                                   application_id: @application.id,
                                   value: value,
                                   index: index,
                                   person: person
                                 })
        end
      end
    end
  end # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
