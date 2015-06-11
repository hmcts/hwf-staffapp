class HealthStatus

  def self.current_status
    {
      ok: [database].all?,
      database: {
        description: "Postgres database",
        ok: database,
      }
    }
  end

  def self.database
    begin
      ActiveRecord::Base.connection.active?
    rescue PG::ConnectionBad
      false
    end
  end
end
