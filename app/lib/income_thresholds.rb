class IncomeThresholds
  def initialize(married, children)
    @married = married
    @children = children
  end

  def min_threshold
    settings.min_threshold_base + married_supplement + children_supplement
  end

  def max_threshold
    settings.max_threshold_base + married_supplement + children_supplement
  end

  private

  def settings
    Settings.income
  end

  def children_supplement
    @children * settings.per_child_increment
  end

  def married_supplement
    @married ? settings.married_supplement : 0
  end
end
