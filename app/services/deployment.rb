class Deployment

  def self.info
    {
      version_number: ENV['APPVERSION'] || 'unknown',
      build_date: ENV['APP_BUILD_DATE'] || 'unknown',
      commit_id: ENV['APP_GIT_COMMIT'] || 'unknown',
      build_tag: ENV['APP_BUILD_TAG'] || 'unknown'
    }
  end

end
