require 'rails_helper'

RSpec.describe Forms::Application::Partner do
  subject(:created_partner) { described_class.new(personal_information) }

  params_list = [:partner_last_name, :partner_date_of_birth, :day_date_of_birth, :month_date_of_birth, :year_date_of_birth,
                 :partner_first_name, :partner_ni_number, :ni_number]

  let(:personal_information) { attributes_for(:personal_information) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:partner_first_name).is_at_least(2) }
    it { is_expected.to validate_length_of(:partner_last_name).is_at_least(2) }

    describe 'partner_date_of_birth' do
      let(:day_date_of_birth) { 1 }
      let(:month_date_of_birth) { 10 }
      let(:year_date_of_birth) { 10.years.ago }

      context 'partner_date_of_birth dates' do
        before do
          personal_information[:day_date_of_birth] = day_date_of_birth
          personal_information[:month_date_of_birth] = month_date_of_birth
          personal_information[:year_date_of_birth] = year_date_of_birth
        end

        context "day is blank" do
          let(:day_date_of_birth) { nil }
          it { expect(created_partner.valid?).to be true }
        end

        context "month is blank" do
          let(:month_date_of_birth) { nil }
          it { expect(created_partner.valid?).to be true }
        end

        context "year is blank" do
          let(:year_date_of_birth) { nil }
          it { expect(created_partner.valid?).to be true }
        end

      end

      context 'when the partner_date_of_birth is less than minimum age allowed' do
        let(:minimum_age) { Time.zone.today + 1.day }

        before do
          personal_information[:day_date_of_birth] = minimum_age.day
          personal_information[:month_date_of_birth] = minimum_age.month
          personal_information[:year_date_of_birth] = minimum_age.year
        end

        it { expect(created_partner.valid?).not_to be true }

        describe 'error message' do
          before { created_partner.valid? }
          let(:error) { ["Partner's date of birth cannot be in the future"] }

          it { expect(created_partner.errors[:partner_date_of_birth]).to eql error }
        end
      end

      context 'when the partner_date_of_birth exceeds maximum allowed age' do
        let(:maximum_age) { Time.zone.today - (described_class::MAXIMUM_AGE + 1).years }

        before do
          personal_information[:day_date_of_birth] = maximum_age.day
          personal_information[:month_date_of_birth] = maximum_age.month
          personal_information[:year_date_of_birth] = maximum_age.year
        end

        it { expect(created_partner.valid?).not_to be true }

        describe 'error message' do
          before { created_partner.valid? }
          let(:error) { ["The partner can't be over #{described_class::MAXIMUM_AGE} years old"] }

          it { expect(created_partner.errors[:partner_date_of_birth]).to eql error }
        end
      end

      context 'when the the partner_date_of_birth is passed a two digit year' do

        before do
          personal_information[:day_date_of_birth] = 1
          personal_information[:month_date_of_birth] = 11
          personal_information[:year_date_of_birth] = 80
        end

        it { expect(created_partner.valid?).not_to be true }

        it 'returns an error message, if omitted' do
          created_partner.valid?
          expect(created_partner.errors[:partner_date_of_birth]).to eq ['Enter a valid date of birth']
        end
      end
    end

    describe 'partner_ni_number' do
      context 'when valid' do
        before { personal_information[:partner_ni_number] = 'AB112233A' }

        it 'passes validation' do
          expect(created_partner.valid?).to be true
        end
      end

      context 'when blank' do
        before { created_partner.partner_ni_number = '' }

        it 'passes validation' do
          expect(created_partner.valid?).to be true
        end
      end

      context "when ni_number and partner_ni_number are the same" do
        let(:personal_information) do
          attributes_for(:personal_information, ni_number: 'AB123456C', partner_ni_number: 'AB123456C')
        end

        it "is not valid" do
          expect(created_partner.valid?).to be false
        end
      end

      context 'when invalid' do
        before { created_partner.partner_ni_number = 'FOOBAR' }

        it 'passes validation' do
          expect(created_partner.valid?).to be false
        end
      end

      context 'when passed in as lower case' do
        before { created_partner.partner_ni_number = 'ab112233a' }

        it 'up-cases it to pass the validation' do
          expect(created_partner.valid?).to be true
        end
      end

      context 'when white space is passed in' do
        before { created_partner.partner_ni_number = ' AB112233A' }

        it 'strips it away to pass the validation' do
          expect(created_partner.valid?).to be true
        end
      end
    end
    ['partner_first_name', 'partner_last_name'].each do |attribute|
      describe attribute.to_s do
        context 'when valid' do
          before { personal_information[attribute.to_sym] = 'Mr' }

          it 'passes validation' do
            expect(created_partner.valid?).to be true
          end
        end

        context 'when white space is passed in' do
          before do
            personal_information[attribute.to_sym] = ' sm it '
            created_partner.valid?
          end

          it 'strips it away' do
            expect(created_partner.send(attribute)).to eql('sm it')
          end
        end
      end
    end
  end

  describe 'when Applicant object is passed in' do
    let(:applicant) { build(:applicant, :married) }
    let(:form) { described_class.new(applicant) }

    params_list.each do |attr_name|
      next if /day|month|year/.match?(attr_name.to_s)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq applicant.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { attributes_for(:full_personal_information) }
    let(:form) { described_class.new(hash) }

    most_attribs = params_list - [:partner_date_of_birth]

    most_attribs.each do |attr_name|
      next if /day|month|year/.match?(attr_name.to_s)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name]
      end
    end

    it 'assign partner_date_of_birth attribute' do
      day = hash[:day_date_of_birth]
      month = hash[:month_date_of_birth]
      year = hash[:year_date_of_birth]
      form.valid?
      expect(form.partner_date_of_birth).to eq "#{day}/#{month}/#{year}".to_date
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(applicant) }

    subject(:form_save) do
      form.update(params)
      form.save
    end

    let(:applicant) { application.applicant }
    let(:application) { create(:application, :applicant_full, married: true) }

    context 'when the attributes are correct' do
      let(:dob) { '01/01/1980' }
      let(:params) do
        {
          partner_last_name: 'foo',
          partner_first_name: 'bar',
          day_date_of_birth: '01',
          month_date_of_birth: '01',
          year_date_of_birth: '1980',
          partner_ni_number: 'AB123456A'
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
          next if /day|month|year/.match?(key.to_s)
          expect(applicant.send(key)).to eql(value)
        end
      end

      it 'saves the correct date of birth' do
        expect(applicant.partner_date_of_birth).to eql(parsed_dob)
      end
    end

    context 'when the attributes are incorrect' do
      let(:params) do
        {
          partner_last_name: '',
          day_date_of_birth: '01',
          month_date_of_birth: '01',
          year_date_of_birth: '1000'
        }
      end

      it 'returns false' do
        is_expected.to be false
      end
    end

    context 'when married is true but no applicant NI number' do
      let(:application) { create(:application, :applicant_full, married: true, ni_number: nil) }
      let(:params) { { partner_first_name: 'John', partner_last_name: 'Doe', partner_ni_number: 'AB123456C' } }

      before do
        form_save
        applicant.reload
      end

      it 'clears partner details' do
        expect(applicant.partner_first_name).to be_nil
        expect(applicant.partner_last_name).to be_nil
        expect(applicant.partner_ni_number).to be_nil
      end
    end

    context 'when married is false but applicant provides an NI number' do
      let(:application) { create(:application, :applicant_full, married: false, ni_number: 'AB123456C') }
      let(:params) { { partner_first_name: 'John', partner_last_name: 'Doe', partner_ni_number: 'AB123456C' } }

      before do
        form_save
        applicant.reload
      end

      it 'clears partner details' do
        expect(applicant.partner_first_name).to be_nil
        expect(applicant.partner_last_name).to be_nil
        expect(applicant.partner_ni_number).to be_nil
      end
    end
  end
end
