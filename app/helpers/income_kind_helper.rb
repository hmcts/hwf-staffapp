module IncomeKindHelper
  def income_kinds
    # just array for index iteration
    (1..20).to_a
  end

  def kind_checked(application, form, claimant, kind)
    return false if application.income_kind.blank?

    application.income_kind[claimant].include? t(kind, scope: [form.i18n_scope, 'kinds'])
  end
end
