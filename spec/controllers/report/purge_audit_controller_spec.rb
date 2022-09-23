
RSpec.describe Report::PurgeAuditController do
  let(:admin) { create :admin_user }
  let(:user) { create :user }

  describe '#show' do
    subject { response }

    context 'admin' do
      before {
        sign_in admin
        get :show
      }

      it { is_expected.to render_template 'reports/purged_audit' }
    end

    context 'user' do
      before {
        sign_in user
        get :show
      }

      it { is_expected.not_to render_template 'reports/purged_audit' }
    end

  end

  describe '#data_export' do
    let(:date_from) { { day: "01", month: "01", year: "2015" } }
    let(:date_to) { { day: "31", month: "12", year: "2015" } }
    let(:dates) {
      { day_date_from: '01',
        month_date_from: '01',
        year_date_from: '2015',
        day_date_to: '31',
        month_date_to: '12',
        year_date_to: '2015' }
    }

    context 'admin' do
      before {
        allow(Views::Reports::AuditPersonalDataReport).to receive(:new).and_return([])
        sign_in admin
        put :data_export, params: { forms_finance_report: dates }
      }

      it {
        expect(Views::Reports::AuditPersonalDataReport).to have_received(:new).with(date_from, date_to)
      }
    end

    context 'user' do
      before {
        allow(Views::Reports::AuditPersonalDataReport).to receive(:new).and_return([])
        sign_in user
        put :data_export, params: { forms_finance_report: dates }
      }

      it {
        expect(Views::Reports::AuditPersonalDataReport).not_to have_received(:new)
      }
    end
  end
end
