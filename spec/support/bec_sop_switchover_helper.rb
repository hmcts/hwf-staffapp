
def reference_change_date
  if Settings.reference.date.is_a?(Date)
    Settings.reference.date
  else
    Time.zone.parse(Settings.reference.date)
  end
end
