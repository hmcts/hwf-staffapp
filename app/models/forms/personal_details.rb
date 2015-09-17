module Forms
  class PersonalDetails

    include ActiveModel::Validations

    attr_accessor :last_name
    attr_accessor :date_of_birth
    attr_accessor :married

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, inclusion: { in: [true, false] }

    def permitted_attributes
      %i[title first_name last_name date_of_birth ni_number married]
    end
  end
end
