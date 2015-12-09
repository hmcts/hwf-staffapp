require 'rails_helper'

RSpec.describe ReferenceTableHelper, type: :helper do

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
end
