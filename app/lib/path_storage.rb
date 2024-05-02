class PathStorage

  def initialize(user)
    @user_key = "application-path-#{user.id}"
  end

  def navigation(current_path)
    return if load_last == current_path

    # TODO: - when going from summary page remove steps

    if load_previous == current_path
      remove_last_path_from_list
    else
      add_path_to_list(current_path)
    end
  end

  def path_back
    load_previous
  end

  def clear!
    storage.set(@user_key, nil)
  end

  private

  def storage
    @storage ||= Redis.new
  end

  def load_navigation_list
    storage_value = storage.get(@user_key)
    list = storage_value.blank? ? '[]' : storage.get(@user_key)
    @navigation_list = JSON.parse(list)
  end

  def add_path_to_list(path)
    @navigation_list << path
    storage.set(@user_key, @navigation_list.to_json)
  end

  def remove_last_path_from_list
    path = @navigation_list.pop
    storage.set(@user_key, @navigation_list.to_json)
    path
  end

  def load_previous
    case load_navigation_list.size
    when 0..1
      return ''
    when 2
      position = 0
    else
      position = load_navigation_list.size - 2
    end

    @navigation_list[position]
  end

  def load_last
    load_navigation_list.last
  end

end
