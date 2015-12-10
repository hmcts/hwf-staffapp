require 'rails_helper'

RSpec.describe ReferenceHelper, type: :helper do

  describe '#after_desired_date?' do
    context 'when the date is before 1st January 2016' do
      it 'returns false' do
        Timecop.freeze(Date.new(2015, 12, 31)) do
          expect(helper.after_desired_date?).to eq(false)
        end
      end
    end

    context 'when the date is on or after 1st January 2016' do
      it 'returns false' do
        Timecop.freeze(Date.new(2016, 1, 1)) do
          expect(helper.after_desired_date?).to eq(true)
        end
      end
    end
  end

  describe '#table_header' do
    describe 'date handling' do
      context 'when the date is before 1st January 2016' do
        it 'returns the correct html' do
          Timecop.freeze(Date.new(2015, 12, 31)) do
            header = '<th> Applicant </th>'
            expect(helper.table_header).to eq(header)
          end
        end
      end

      context 'when the date is after 1st January 2016' do
        it 'returns the correct html' do
          Timecop.freeze(Date.new(2016, 1, 1)) do
            header = "<th> Reference </th>\n<th> Applicant </th>"
            expect(helper.table_header).to eq(header)
          end
        end
      end
    end
  end

  describe '#table_column' do
    let(:office) { create :office }
    let(:application) { create :application_full_remission, office: office }
    let(:app) { Views::ApplicationList.new(application) }
    let(:full_name) { app.applicant }
    let(:reference) { app.reference }
    let(:single_column) { "<td> <a href=\"/processed_applications/#{application.id}\">#{full_name}</a> </td>" }
    let(:double_column) { "<td> <a href=\"/processed_applications/#{application.id}\">#{reference}</a> </td>\n<td> #{full_name} </td>" }

    context 'when the date is before 1st January 2016' do
      it 'returns the correct html' do
        Timecop.freeze(Date.new(2015, 12, 31)) do
          expect(helper.table_column(app)).to eq(single_column)
        end
      end
    end

    context 'when the date is after 1st January 2016' do
      it 'returns the correct html' do
        Timecop.freeze(Date.new(2016, 1, 1)) do
          expect(helper.table_column(app)).to eq(double_column)
        end
      end
    end
  end

  describe '#processing_details_options' do
    let(:original_options) { %w[processed_on processed_by] }
    let(:new_options) { %w[processed_on processed_by reference] }

    it 'returns the correct array' do
      Timecop.freeze(Date.new(2015, 12, 31)) do
        expect(helper.processing_details_options).to eq(original_options)
      end
    end

    it 'returns the correct array' do
      Timecop.freeze(Date.new(2016, 1, 1)) do
        expect(helper.processing_details_options).to eq(new_options)
      end
    end
  end

  describe '#display_reference' do
    let(:office) { create :office }
    let(:application) { create :application_full_remission, office: office }
    let(:this_helper) { helper.display_reference(application) }

    context 'when the date is before 1st January 2016' do
      it 'returns the reference' do
        Timecop.freeze(Date.new(2015, 12, 31)) do
          expect(this_helper).to eq('')
        end
      end
    end

    context 'when the date is after 1st January 2016' do
      it 'returns the correct array' do
        Timecop.freeze(Date.new(2016, 1, 1)) do
          expect(this_helper).to eq(application.reference)
        end
      end
    end
  end
end
