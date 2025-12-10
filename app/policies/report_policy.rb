class ReportPolicy < BasePolicy
  def index?
    admin? || mi?
  end

  def show?
    admin? || mi?
  end

  def graphs?
    admin?
  end

  def public?
    admin?
  end

  def letter?
    staff_or_manager? || admin_or_mi? || reader?
  end

  def raw_data?
    admin_or_mi?
  end

  def ocmc_report?
    admin?
  end

  def power_bi?
    admin?
  end

  def hmrc_purged?
    admin_or_mi?
  end

  def purge_audit?
    admin_or_mi?
  end

end
