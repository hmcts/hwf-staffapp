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
  end
end
