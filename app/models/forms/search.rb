module Forms
  class Search
    include Virtus.model(nullify_blank: true)
    include ActiveModel::Model

    attribute :reference, String
    attribute :search_type, String

    validates :reference, presence: true
  end
end
