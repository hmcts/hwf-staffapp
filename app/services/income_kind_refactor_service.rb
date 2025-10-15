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

  INCOME_KIND_MAP = {
    'Wages before tax and National Insurance are taken off' => 'wage',
    'Wages' => 'wage',
    '1' => 'wage',

    'Net profits from self employment' => 'net_profit',
    '2' => 'net_profit',

    'Child Benefit' => 'child_benefit',
    'Child benefit' => 'child_benefit',
    '3' => 'child_benefit',

    'Working Tax Credit' => 'working_credit',
    '4' => 'working_credit',

    'Child Tax Credit' => 'child_credit',
    '5' => 'child_credit',

    'Maintenance payments' => 'maintenance_payments',
    '6' => 'maintenance_payments',

    'Contribution-based Jobseekers Allowance (JSA)' => 'jsa',
    '7' => 'jsa',

    'Contribution-based Employment and Support Allowance (ESA)' => 'esa',
    '8' => 'esa',

    'Universal Credit' => 'universal_credit',
    '9' => 'universal_credit',

    'Pensions (state, work, private, pension credit (savings credit))' => 'pensions',
    'Pensions (state, work, private)' => 'pensions',
    'Pension Credit (savings credit)' => 'pensions',
    '10' => 'pensions',
    '11' => 'pensions',

    'Rent from anyone living with the applicant' => 'rent_from_cohabit',
    'Rent from anyone living with the partner' => 'rent_from_cohabit',
    'Rent from anyone living with you' => 'rent_from_cohabit',
    '12' => 'rent_from_cohabit',
    '14' => 'rent_from_cohabit',

    'Rent from other properties the applicant owns' => 'rent_from_properties',
    'Rent from other properties the partner owns' => 'rent_from_properties',
    'Rent from other properties you own' => 'rent_from_properties',
    '13' => 'rent_from_properties',
    '15' => 'rent_from_properties',

    'Cash gifts - include all one off payments' => 'cash_gifts',
    'Cash gifts' => 'cash_gifts',
    '16' => 'cash_gifts',

    'Financial support from family - include all one off payments' => 'financial_support',
    'Financial support from others' => 'financial_support',
    '17' => 'financial_support',

    'Loans' => 'loans',
    '18' => 'loans',

    'Other income - For example, income from online selling or from dividend or interest payments' => 'other_income',
    'Other income - For example, income from online selling' => 'other_income',
    'Other income  - For example, income from online selling' => 'other_income',
    'Other income' => 'other_income',
    '19' => 'other_income',

    'None of the above' => 'none_of_the_above',
    'No income' => 'none_of_the_above',
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

  def normalize_income_kinds # rubocop:disable Metrics/MethodLength
    [:applicant, :partner].each do |person|
      next unless @application.income_kind[person].is_a?(Array)

      @application.income_kind[person].each_with_index do |value, index|
        normalized = INCOME_KIND_MAP[value]
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
  end # rubocop:enable Metrics/MethodLength
end
