shared_examples 'date_received validation' do
  describe 'presence' do
    before do
      form.date_received = nil
      form.valid?
    end

    it 'is required' do
      expect(form).to be_invalid
    end

    it 'returns an error message, if omitted' do
      expect(form.errors[:date_received]).to eq ['Enter the date in this format DD/MM/YYYY']
    end
  end

  context 'when the format is invalid' do
    before do
      Timecop.freeze(Time.zone.local(2015, 12, 1, 10, 10, 10)) do
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
      context 'is enforced' do
        before { Timecop.freeze(Time.zone.local(2014, 10, 1, 12, 30, 0)) }
        after { Timecop.return }

        it 'allows today' do
          form.date_received = Time.zone.local(2014, 10, 1)
          expect(form).to be_valid
        end

        it 'allows 3 months ago' do
          form.date_received = Time.zone.local(2014, 7, 1, 0, 30)
          expect(form).to be_valid
        end

        describe 'maximum' do
          before do
            form.date_received = Time.zone.local(2014, 6, 30, 16, 30, 0)
            form.valid?
          end

          it 'is 3 months' do
            expect(form).to be_invalid
          end

          it 'returns an error if exceeded' do
            expect(form.errors[:date_received]).to eq ['The application must have been made in the last 3 months']
          end
        end

        describe 'minimum' do
          before do
            form.date_received = Date.new(2014, 10, 2)
            form.valid?
          end

          it 'is today' do
            expect(form).to be_invalid
          end

          it 'returns an error if too low' do
            expect(form.errors[:date_received]).to eq ["This date can't be in the future"]
          end
        end
      end
    end
  end

end
