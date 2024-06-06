class OnlineApplicationBuilder

  def initialize(object)
    @source = object
  end

  def build
    generator = HwfReferenceGenerator.new(@source['benefits'])
    @source.merge!(generator.attributes)
    OnlineApplication.new(@source)
  end
end
