module UserHelper
  def jurisdiction_name(user)
    name = user.jurisdiction.try(:name)
    name || 'No main jurisdiction'
  end
end
