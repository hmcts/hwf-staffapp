# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeeCodesFreshnessChecker do
  subject(:checker) { described_class.new }

  let(:tmp_dir) { described_class::FEE_CODES_DIR }

  describe '#cleanup_old_files!' do
    context 'when there are multiple fee code files' do
      let(:old_file) { tmp_dir.join("approvedFees_2026-02-28.json").to_s }
      let(:older_file) { tmp_dir.join("approvedFees_2026-02-27.json").to_s }
      let(:current_file) { tmp_dir.join("approvedFees_2026-03-02.json").to_s }

      before do
        allow(Dir).to receive(:glob).and_return([older_file, old_file, current_file])
        allow(File).to receive(:delete)
        allow(Rails.logger).to receive(:info)
      end

      it 'deletes all but the most recent file by default' do
        checker.cleanup_old_files!
        expect(File).to have_received(:delete).with(older_file)
        expect(File).to have_received(:delete).with(old_file)
        expect(File).not_to have_received(:delete).with(current_file)
      end

      it 'keeps the specified number of files' do
        checker.cleanup_old_files!(keep: 2)
        expect(File).to have_received(:delete).with(older_file)
        expect(File).not_to have_received(:delete).with(old_file)
        expect(File).not_to have_received(:delete).with(current_file)
      end
    end

    context 'when there is only one file' do
      before do
        allow(Dir).to receive(:glob).and_return([tmp_dir.join("approvedFees_2026-03-02.json").to_s])
        allow(File).to receive(:delete)
      end

      it 'does not delete anything' do
        checker.cleanup_old_files!
        expect(File).not_to have_received(:delete)
      end
    end

    context 'when there are no files' do
      before do
        allow(Dir).to receive(:glob).and_return([])
        allow(File).to receive(:delete)
      end

      it 'does not delete anything' do
        checker.cleanup_old_files!
        expect(File).not_to have_received(:delete)
      end
    end
  end
end
