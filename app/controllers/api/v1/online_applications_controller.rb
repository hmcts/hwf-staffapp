class Api::V1::OnlineApplicationsController < Api::V1::BaseController
  require 'jwt'
  protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  TOKEN = Settings.submission.token

  before_action :authenticate

  def show
    render(json: 'this is data')
  end

  def create
    begin
      # get thing
      puts '1'
      encrypted_token = params[:application]
      # decrypt thing
      puts '2'
      dcipher = OpenSSL::Cipher.new('aes-256-cbc')
      dcipher.decrypt
      dcipher.key = Settings.cipher.key
      dcipher.iv = Settings.cipher.iv
      puts '3'
      decrypted_token = dcipher.update(encrypted_token.unpack('m')[0])
      decrypted_token << dcipher.final
      puts '4'
      # decode thing
      # ecdsa = OpenSSL::PKey::EC.new(Settings.encryption.public_key)
      ecdsa = OpenSSL::PKey.read(Settings.encryption.public_key.gsub("\\n", "\n"))
      decoded_token = JWT.decode decrypted_token, ecdsa, true, { :algorithm => 'ES512' }
      puts '5'
      # get data
      object = JSON.parse(decoded_token[0]['data'])
      # build thing
      # TODO: Build a thing, use object!
      puts '*'*30
      puts object.inspect
      puts '*'*30
      # return message
      response = { result: 'success', message: 'HWF-16-1234' }
    rescue => e
      response = { result: 'error', message: e.inspect }
    end
    puts "encrypt response: #{response}"
    issuer = Settings.encryption.staff_app_id
    audience = Settings.encryption.public_app_id
    pem = Settings.encryption.private_key
    key = OpenSSL::PKey.read(pem.gsub("\\n", "\n"))

    payload = { data: response.to_json, iss: issuer, aud: audience }
    @jwt = JWT.encode(payload, key, 'ES512')
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = Settings.cipher.key
    cipher.iv = Settings.cipher.iv
    encrypted_string = cipher.update @jwt
    encrypted_string << cipher.final
    final = [encrypted_string].pack('m')

    render text: final, layout: false
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      token == TOKEN
    end
  end
end
