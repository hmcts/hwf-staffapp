module Forms
  class Search
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :reference, :string

    validates :reference, presence: true

    def initialize(attrs = {})
      super(attrs)
      nullify_blanks
    end

    private

    def nullify_blanks
      self.reference = nil if reference.is_a?(String) && reference.blank?
    end
  end
end
