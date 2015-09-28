module Forms
  class PersonalInformation < Base

    include ActiveModel::Validations::Callbacks

    def self.permitted_attributes
      {
        last_name: String,
        date_of_birth: Date,
        married: Boolean,
        title: String,
        ni_number: String,
        first_name: String
      }
    end

    define_attributes

    NI_NUMBER_REGEXP = /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/

    before_validation :format_ni_number

    def format_ni_number
      unless ni_number.nil?
        ni_number.upcase!
        ni_number.gsub!(' ', '')
      end
    end

    validates :last_name, presence: true, length: { minimum: 2 }
    validates :date_of_birth, presence: true
    validates :married, inclusion: { in: [true, false] }
    validates :ni_number, format: { with: NI_NUMBER_REGEXP }, allow_blank: true
  end
end
