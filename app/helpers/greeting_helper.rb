module GreetingHelper

  def greeting_condition(confirm, application)
    if confirm.representative_full_name
      "#{confirm.representative_full_name} regarding #{application.applicant.full_name}"
    else
      application.applicant.full_name
    end
  end

  def greeting_condition2(representative, applicant)
    representative.full_name ? "#{representative.full_name} regarding #{applicant.full_name}" : applicant.full_name
  end
end
