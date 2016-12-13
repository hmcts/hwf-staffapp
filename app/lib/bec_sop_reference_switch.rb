class BecSopReferenceSwitch
  def self.use_new_reference_type
    Time.zone.now >= Settings.reference.date
  end
end
