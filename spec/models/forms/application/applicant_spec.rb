require 'rails_helper'

RSpec.describe Forms::Application::Applicant do
  subject(:created_applicant) { described_class.new(personal_information) }

  params_list = [:last_name, :date_of_birth, :day_date_of_birth, :month_date_of_birth, :year_date_of_birth,
                 :married, :title, :first_name, :ni_number]

  let(:personal_information) { attributes_for :personal_information }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    describe 'date_of_birth' do

      context 'when the date_of_birth is less than minimum age allowed' do
        let(:minimum_age) { Time.zone.today - (described_class::MINIMUM_AGE - 1).years }

        before do
          personal_information[:day_date_of_birth] = minimum_age.day
          personal_information[:month_date_of_birth] = minimum_age.month
          personal_information[:year_date_of_birth] = minimum_age.year
        end

        it { expect(created_applicant.valid?).not_to be true }

        describe 'error message' do
          before { created_applicant.valid? }
          let(:error) { ["The applicant can't be under #{described_class::MINIMUM_AGE} years old"] }

          it { expect(created_applicant.errors[:date_of_birth]).to eql error }
        end
      end

      context 'when the date_of_birth exceeds maximum allowed age' do
        let(:maximum_age) { Time.zone.today - (described_class::MAXIMUM_AGE + 1).years }

        before do
          personal_information[:day_date_of_birth] = maximum_age.day
          personal_information[:month_date_of_birth] = maximum_age.month
          personal_information[:year_date_of_birth] = maximum_age.year
        end

        it { expect(created_applicant.valid?).not_to be true }

        describe 'error message' do
          before { created_applicant.valid? }
          let(:error) { ["The applicant can't be over #{described_class::MAXIMUM_AGE} years old"] }

          it { expect(created_applicant.errors[:date_of_birth]).to eql error }
        end
      end

      context 'when the the date_of_birth is passed a two digit year' do

        before do
          personal_information[:day_date_of_birth] = 1
          personal_information[:month_date_of_birth] = 11
          personal_information[:year_date_of_birth] = 80
        end

        it { expect(created_applicant.valid?).not_to be true }

        it 'returns an error message, if omitted' do
          created_applicant.valid?
          expect(created_applicant.errors[:date_of_birth]).to eq ['Enter a valid date of birth']
        end
      end
    end

    describe 'married' do
      context 'when true' do
        before { personal_information[:married] = true }

        it { expect(created_applicant.valid?).to be true }
      end

      context 'when false' do
        before { personal_information[:married] = false }

        it { expect(created_applicant.valid?).to be true }
      end

      context 'when not a boolean value' do
        before { personal_information[:married] = 'string' }

        it { expect(created_applicant.valid?).to be false }
      end
    end

    describe 'ni_number' do
      context 'when valid' do
        before { personal_information[:ni_number] = 'AB112233A' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when blank' do
        before { created_applicant.ni_number = '' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when invalid' do
        before { created_applicant.ni_number = 'FOOBAR' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be false
        end
      end

      context 'when passed in as lower case' do
        before { created_applicant.ni_number = 'ab112233a' }

        it 'up-cases it to pass the validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when white space is passed in' do
        before { created_applicant.ni_number = ' AB112233A' }

        it 'strips it away to pass the validation' do
          expect(created_applicant.valid?).to be true
        end
      end
    end
    ['title', 'first_name', 'last_name'].each do |attribute|
      describe attribute.to_s do
        context 'when valid' do
          before { personal_information[attribute.to_sym] = 'Mr' }

          it 'passes validation' do
            expect(created_applicant.valid?).to be true
          end
        end

        context 'when white space is passed in' do
          before do
            personal_information[attribute.to_sym] = ' sm it '
            created_applicant.valid?
          end

          it 'strips it away' do
            expect(created_applicant.send(attribute)).to eql('sm it')
          end
        end
      end
    end

  end

  describe 'when Applicant object is passed in' do
    let(:applicant) { build(:applicant) }
    let(:form) { described_class.new(applicant) }

    params_list.each do |attr_name|
      next if attr_name.to_s.match(/day|month|year/)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq applicant.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { attributes_for :full_personal_information }
    let(:form) { described_class.new(hash) }
    most_attribs = params_list.reject { |k, _| k == :date_of_birth }

    most_attribs.each do |attr_name|
      next if attr_name.to_s.match(/day|month|year/)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name]
      end
    end

    it 'assign date_of_birth attribute' do
      day = hash[:day_date_of_birth]
      month = hash[:month_date_of_birth]
      year = hash[:year_date_of_birth]
      form.valid?
      expect(form.date_of_birth).to eq "#{day}/#{month}/#{year}".to_date
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(applicant) }

    subject(:form_save) do
      form.update_attributes(params)
      form.save
    end

    let(:applicant) { create :applicant }

    context 'when the attributes are correct' do
      let(:dob) { '01/01/1980' }
      let(:params) do
        {
          title: 'Mr',
          last_name: 'foo',
          first_name: 'bar',
          day_date_of_birth: '01',
          month_date_of_birth: '01',
          year_date_of_birth: '1980',
          married: true,
          ni_number: 'AB123456A'
        }
      end

      let(:parsed_dob) { Date.parse(dob) }

      it { is_expected.to be true }

      before do
        form_save
        applicant.reload
      end

      it 'saves the parameters in the applicant' do
        params.each do |key, value|
          next if key.to_s.match(/day|month|year/)
          expect(applicant.send(key)).to eql(value)
        end
      end

      it 'saves the correct date of birth' do
        expect(applicant.date_of_birth).to eql(parsed_dob)
      end
    end

    context 'when the attributes are incorrect' do
      let(:dob) { '01/01/1980' }
      let(:params) { { last_name: '' } }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end
end
