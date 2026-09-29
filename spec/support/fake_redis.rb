# Minimal in-memory stand-in for Redis used by the test suites.
# PathStorage only needs get/set; add methods here if the app starts using more.
class FakeRedis
  def initialize
    @data = {}
  end

  def get(key)
    @data[key]
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  def del(key)
    @data.delete(key).nil? ? 0 : 1
  end
end
