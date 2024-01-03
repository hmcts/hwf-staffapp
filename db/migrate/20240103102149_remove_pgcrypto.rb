class RemovePgcrypto < ActiveRecord::Migration[7.0]
  def up
    disable_extension 'pgcrypto' if server_version >= 13.0
  end

  def down
    enable_extension 'pgcrypto' if server_version < 13.0 || !extension_enabled?('pgcrypto')
  end

  private

  def server_version
    ActiveRecord::Base.connection.select_value('SELECT version()').split(' ')[1].split('.')[0..1].join('.').to_f
  end
end