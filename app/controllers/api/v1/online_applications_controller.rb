class Api::V1::OnlineApplicationsController < Api::V1::BaseController
  require 'jwt'
  protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  TOKEN = "secret"

  before_action :authenticate

  def show
    render(json: 'this is data')
  end

  def create
    # get thing
    encrypted_token = params[:application]
    # decrypt thing
    dcipher = OpenSSL::Cipher.new('aes-256-cbc')
    dcipher.decrypt
    dcipher.key = '3�ď/O�����)&��V[��~��J��J'
    dcipher.iv = 'msB���]��?�z'
    decrypted_token = dcipher.update(encrypted_token.unpack('m')[0])
    decrypted_token << dcipher.final
    # decode thing
    pub_key = File.read('/home/colinbruce/projects/api_test/fr-staff.public.pem')
    ecdsa = OpenSSL::PKey::EC.new(pub_key)
    decoded_token = JWT.decode decrypted_token, ecdsa, true, { :algorithm => 'ES512' }
    # get data
    object = JSON.parse(decoded_token[0]['data'])
    # build thing
    # TODO: Build a thing, use object!
    # return message
    render(json: { result: 'success', message: 'HWF-16-1234' } )
  rescue => e
    render(json: { result: 'error', message: e.inspect })
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == TOKEN
    end
  end
end
