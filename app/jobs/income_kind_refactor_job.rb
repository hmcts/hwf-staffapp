class IncomeKindRefactorJob < ApplicationJob
  queue_as :urgent

  def perform
    @task_name = 'PartnerValuesRefactor'
    log_task_run('start', @task_name)
    update_partner_values
    log_task_run('end', @task_name)
    @task_name = 'IncomeKindsRefactor'
    log_task_run('start', @task_name)
    update_income_kinds
    log_task_run('end', @task_name)
  end

  private

  def update_partner_values
    Application.where.not(income_kind: [blank?, {}]).find_each do |application|
      if application.income_kind[:partner].present?
        if application.income_kind[:partner].include?('Rent from anyone living with the applicant') ||
          application.income_kind[:partner].include?('Rent from other properties the applicant owns')
          application.income_kind[:partner].each_with_index do |value, index|
            if value == 'Rent from anyone living with the applicant'
              application.income_kind[:partner][index] = 'Rent from anyone living with the partner'
            elsif value == 'Rent from other properties the applicant owns'
              application.income_kind[:partner][index] = 'Rent from other properties the partner owns'
            end
          end
        end
        application.save!
      end
    end

    OnlineApplication.where.not(income_kind: [blank?, {}]).find_each do |application|
      if application.income_kind['partner'].present?
        if application.income_kind['partner'].include?('Rent from anyone living with the applicant') ||
          application.income_kind['partner'].include?('Rent from other properties the applicant owns')
          application.income_kind['partner'].each_with_index do |value, index|
            if value == 'Rent from anyone living with the applicant'
              application.income_kind['partner'][index] = 'Rent from anyone living with the partner'
            elsif value == 'Rent from other properties the applicant owns'
              application.income_kind['partner'][index] = 'Rent from other properties the partner owns'
            end
          end
        end
        application.save!
      end
    end

    Application.where.not(income_kind: [blank?, {}]).find_each do |application|
      if application.income_kind[:applicant].present?
        if application.income_kind[:applicant].include?('Rent from anyone living with the partner') ||
          application.income_kind[:applicant].include?('Rent from other properties the partner owns')
          application.income_kind[:applicant].each_with_index do |value, index|
            if value == 'Rent from anyone living with the partner'
              application.income_kind[:applicant][index] = 'Rent from anyone living with the applicant'
            elsif value == 'Rent from other properties the partner owns'
              application.income_kind[:applicant][index] = 'Rent from other properties the applicant owns'
            end
          end
        end
        application.save!
      end
    end

    OnlineApplication.where.not(income_kind: [blank?, {}]).find_each do |application|
      if application.income_kind['applicant'].present?
        if application.income_kind['applicant'].include?('Rent from anyone living with the partner') ||
          application.income_kind['partner'].include?('Rent from other properties the partner owns')
          application.income_kind['applicant'].each_with_index do |value, index|
            if value == 'Rent from anyone living with the partner'
              application.income_kind['applicant'][index] = 'Rent from anyone living with the applicant'
            elsif value == 'Rent from other properties the partner owns'
              application.income_kind['applicant'][index] = 'Rent from other properties the applicant owns'
            end
          end
        end
        application.save!
      end
    end
  end

  def update_income_kinds
    Application.where.not(income_kind: blank?).find_each do |application|
      if application.income_kind[:applicant].present?
        application.income_kind[:applicant].each_with_index do |value, index|
          case value

          when 'Wages before tax and National Insurance are taken off', 'Wages', '1'
            application.income_kind[:applicant][index] = 'wage'
          when 'Net profits from self employment', '2'
            application.income_kind[:applicant][index] = 'net_profit'
          when 'Child Benefit', 'Child benefit', '3'
            application.income_kind[:applicant][index] = 'child_benefit'
          when 'Working Tax Credit', '4'
            application.income_kind[:applicant][index] = 'working_credit'
          when 'Child Tax Credit', '5'
            application.income_kind[:applicant][index] = 'child_credit'
          when 'Maintenance payments', '6'
            application.income_kind[:applicant][index] = 'maintenance_payments'
          when 'Contribution-based Jobseekers Allowance (JSA)', '7'
            application.income_kind[:applicant][index] = 'jsa'
          when 'Contribution-based Employment and Support Allowance (ESA)', '8'
            application.income_kind[:applicant][index] = 'esa'
          when 'Universal Credit', '9'
            application.income_kind[:applicant][index] = 'universal_credit'
          when 'Pensions (state, work, private, pension credit (savings credit))', 'Pensions (state, work, private)',
            'Pension Credit (savings credit)', '10', '11'
            application.income_kind[:applicant][index] = 'pensions'
          when 'Rent from anyone living with the applicant', 'Rent from anyone living with you', '12', '14'
            application.income_kind[:applicant][index] = 'rent_from_cohabit'
          when 'Rent from other properties the applicant owns', 'Rent from other properties you own', '13', '15'
            application.income_kind[:applicant][index] = 'rent_from_properties'
          when 'Cash gifts - include all one off payments', 'Cash gifts', '16'
            application.income_kind[:applicant][index] = 'cash_gifts'
          when 'Financial support from family - include all one off payments', 'Financial support from others', '17'
            application.income_kind[:applicant][index] = 'financial_support'
          when 'Loans', '18'
            application.income_kind[:applicant][index] = 'loans'
          when 'Other income - For example, income from online selling or from dividend or interest payments',
            'Other income', 'Other income - For example, income from online selling',
            'Other income  - For example, income from online selling', '19'
            application.income_kind[:applicant][index] = 'other_income'
          when 'None of the above', 'No income', '20'
            application.income_kind[:applicant][index] = 'none_of_the_above'
          else
            Sentry.capture_message("no income kind match",
                                   extra: { application_type: 'paper', application_id: application.id, value: value,
                                            index: index, person: 'applicant' })
          end
          application.save!
        end

      end

      if application.income_kind[:partner].present?
        application.income_kind[:partner].each_with_index do |value, index|
          case value

          when 'Wages before tax and National Insurance are taken off', 'Wages', '1'
            application.income_kind[:partner][index] = 'wage'
          when 'Net profits from self employment', '2'
            application.income_kind[:partner][index] = 'net_profit'
          when 'Child Benefit', 'Child benefit', '3'
            application.income_kind[:partner][index] = 'child_benefit'
          when 'Working Tax Credit', '4'
            application.income_kind[:partner][index] = 'working_credit'
          when 'Child Tax Credit', '5'
            application.income_kind[:partner][index] = 'child_credit'
          when 'Maintenance payments', '6'
            application.income_kind[:partner][index] = 'maintenance_payments'
          when 'Contribution-based Jobseekers Allowance (JSA)', '7'
            application.income_kind[:partner][index] = 'jsa'
          when 'Contribution-based Employment and Support Allowance (ESA)', '8'
            application.income_kind[:partner][index] = 'esa'
          when 'Universal Credit', '9'
            application.income_kind[:partner][index] = 'universal_credit'
          when 'Pensions (state, work, private, pension credit (savings credit))', 'Pensions (state, work, private)',
            'Pension Credit (savings credit)', '10', '11'
            application.income_kind[:partner][index] = 'pensions'
          when 'Rent from anyone living with the partner', 'Rent from anyone living with you', '12', '14'
            application.income_kind[:partner][index] = 'rent_from_cohabit'
          when 'Rent from other properties the partner owns', 'Rent from other properties you own', '13', '15'
            application.income_kind[:partner][index] = 'rent_from_properties'
          when 'Cash gifts - include all one off payments', 'Cash gifts', '16'
            application.income_kind[:partner][index] = 'cash_gifts'
          when 'Financial support from family - include all one off payments', 'Financial support from others', '17'
            application.income_kind[:partner][index] = 'financial_support'
          when 'Loans', '18'
            application.income_kind[:partner][index] = 'loans'
          when 'Other income - For example, income from online selling or from dividend or interest payments',
            'Other income', 'Other income - For example, income from online selling',
            'Other income  - For example, income from online selling', '19'
            application.income_kind[:partner][index] = 'other_income'
          when 'None of the above', 'No income', '20'
            application.income_kind[:partner][index] = 'none_of_the_above'
          else
            Sentry.capture_message("no income kind match",
                                   extra: { application_type: 'paper', application_id: application.id, value: value,
                                            index: index, person: 'partner' })
          end
          application.save!
        end
      end
    end

    OnlineApplication.where.not(income_kind: blank?).find_each do |application|
      if application.income_kind[:applicant].present?
        application.income_kind[:applicant].each_with_index do |value, index|
          case value

          when 'Wages before tax and National Insurance are taken off', 'Wages'
            application.income_kind[:applicant][index] = 'wage'
          when 'Net profits from self employment'
            application.income_kind[:applicant][index] = 'net_profit'
          when 'Child Benefit', 'Child benefit'
            application.income_kind[:applicant][index] = 'child_benefit'
          when 'Working Tax Credit'
            application.income_kind[:applicant][index] = 'working_credit'
          when 'Child Tax Credit'
            application.income_kind[:applicant][index] = 'child_credit'
          when 'Maintenance payments'
            application.income_kind[:applicant][index] = 'maintenance_payments'
          when 'Contribution-based Jobseekers Allowance (JSA)'
            application.income_kind[:applicant][index] = 'jsa'
          when 'Contribution-based Employment and Support Allowance (ESA)'
            application.income_kind[:applicant][index] = 'esa'
          when 'Universal Credit'
            application.income_kind[:applicant][index] = 'universal_credit'
          when 'Pensions (state, work, private, pension credit (savings credit))', 'Pensions (state, work, private)',
            'Pension Credit (savings credit)'
            application.income_kind[:applicant][index] = 'pensions'
          when 'Rent from anyone living with the applicant', 'Rent from anyone living with you'
            application.income_kind[:applicant][index] = 'rent_from_cohabit'
          when 'Rent from other properties the applicant owns', 'Rent from other properties you own'
            application.income_kind[:applicant][index] = 'rent_from_properties'
          when 'Cash gifts - include all one off payments', 'Cash gifts'
            application.income_kind[:applicant][index] = 'cash_gifts'
          when 'Financial support from family - include all one off payments', 'Financial support from others'
            application.income_kind[:applicant][index] = 'financial_support'
          when 'Loans'
            application.income_kind[:applicant][index] = 'loans'
          when 'Other income - For example, income from online selling or from dividend or interest payments',
            'Other income', 'Other income - For example, income from online selling',
            'Other income  - For example, income from online selling'
            application.income_kind[:applicant][index] = 'other_income'
          when 'None of the above', 'No income'
            application.income_kind[:applicant][index] = 'none_of_the_above'
          else
            Sentry.capture_message("no income kind match",
                                   extra: { application_type: 'online', application_id: application.id, value: value,
                                            index: index, person: 'applicant' })
          end
          application.save!
        end
      end

      if application.income_kind[:partner].present?
        application.income_kind[:partner].each_with_index do |value, index|
          case value

          when 'Wages before tax and National Insurance are taken off', 'Wages'
            application.income_kind[:partner][index] = 'wage'
          when 'Net profits from self employment'
            application.income_kind[:partner][index] = 'net_profit'
          when 'Child Benefit', 'Child benefit'
            application.income_kind[:partner][index] = 'child_benefit'
          when 'Working Tax Credit'
            application.income_kind[:partner][index] = 'working_credit'
          when 'Child Tax Credit'
            application.income_kind[:partner][index] = 'child_credit'
          when 'Maintenance payments'
            application.income_kind[:partner][index] = 'maintenance_payments'
          when 'Contribution-based Jobseekers Allowance (JSA)'
            application.income_kind[:partner][index] = 'jsa'
          when 'Contribution-based Employment and Support Allowance (ESA)'
            application.income_kind[:partner][index] = 'esa'
          when 'Universal Credit'
            application.income_kind[:partner][index] = 'universal_credit'
          when 'Pensions (state, work, private, pension credit (savings credit))', 'Pensions (state, work, private)',
            'Pension Credit (savings credit)'
            application.income_kind[:partner][index] = 'pensions'
          when 'Rent from anyone living with the partner', 'Rent from anyone living with you'
            application.income_kind[:partner][index] = 'rent_from_cohabit'
          when 'Rent from other properties the partner owns', 'Rent from other properties you own'
            application.income_kind[:partner][index] = 'rent_from_properties'
          when 'Cash gifts - include all one off payments', 'Cash gifts'
            application.income_kind[:partner][index] = 'cash_gifts'
          when 'Financial support from family - include all one off payments', 'Financial support from others'
            application.income_kind[:partner][index] = 'financial_support'
          when 'Loans'
            application.income_kind[:partner][index] = 'loans'
          when 'Other income - For example, income from online selling or from dividend or interest payments',
            'Other income', 'Other income - For example, income from online selling',
            'Other income  - For example, income from online selling'
            application.income_kind[:partner][index] = 'other_income'
          when 'None of the above', 'No income'
            application.income_kind[:partner][index] = 'none_of_the_above'
          else
            Sentry.capture_message("no income kind match",
                                   extra: { application_type: 'online', application_id: application.id, value: value,
                                            index: index, person: 'partner' })
          end
          application.save!
        end
      end
    end
  end
end