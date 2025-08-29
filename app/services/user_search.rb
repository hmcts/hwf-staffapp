class UserSearch
  FILTER_LIST = [
    :name,
    :office
  ].freeze

  def initialize(users, filters)
    @users = users
    @filters = filters
  end

  def apply
    FILTER_LIST.each do |filter|
      send(filter, @filters[filter]) if @filters[filter].to_s.present?
    end
    @users
  end

  private

  def office(value)
    @users = @users.where(office_id: value)
  end

  def name(value)
    @users = @users.where("LOWER(name) LIKE ?", "%#{value.strip.downcase}%")
  end
end
