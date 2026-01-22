shared_examples 'date_received validation' do
  describe 'presence' do
    before do
      form.date_received = nil
      form.valid?
    end

    it 'is required' do
      expect(form).not_to be_valid
    end

    it 'returns an error message, if omitted' do
      expect(form.errors[:date_received]).to eq ['Enter the date in this format DD/MM/YYYY']
    end
  end

  context 'when the format is invalid' do
    before do
      travel_to(Time.zone.local(2015, 12, 1, 10, 10, 10)) do
        form.day_date_received = '32'
        form.month_date_received = '09'
        form.year_date_received = '2015'
        form.valid?
      end
    end

    it 'sets an error on date_received field' do
      expect(form.errors[:date_received]).to eq ['Enter the date in this format DD/MM/YYYY']
    end
  end

  context 'when the format is valid' do
    describe 'range' do
      describe 'date_received' do

        it 'is in the future' do
          travel_to(Time.zone.local(2014, 10, 1, 12, 30, 0)) do
            received = Time.zone.local(2014, 10, 3, 12, 30, 0)

            form.date_received = received
            form.year_date_received = received.year
            form.month_date_received = received.month
            form.day_date_received = received.day

            form.valid?

            expect(form.errors[:date_received]).to eq ["This date can't be in the future"]
          end
        end
      end
    end
  end

end
