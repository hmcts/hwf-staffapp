# require 'rails_helper'

# RSpec.describe Api::SubmissionsController, type: :controller do
#   let(:auth_token) { 'my-big-secret' }
#   let(:submitted) { attributes_for :public_app_submission }

#   describe 'generate token' do
#     it 'generates correct TTOP secret' do
#       ttp_secret = ENV['HMRC_TTP_SECRET']
#       Timecop.freeze('2021-01-25T00:00:01.000') do
#         totp = ROTP::TOTP.new(ttp_secret, digits: 8, digest: 'sha512')
#         totp.now

#         puts Time.now
#         puts totp.now
#       end
#     end
#   end
# end

