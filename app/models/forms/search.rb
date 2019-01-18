module Forms
  class Search
    include Virtus.model(nullify_blank: true)
    include ActiveModel::Model

    attribute :reference, String

    validates :reference, presence: true
  end
end
