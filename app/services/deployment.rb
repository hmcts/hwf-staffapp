class Deployment

  def self.info
    {
      version_number: ENV.fetch('APPVERSION', 'unknown'),
      build_date: ENV.fetch('APP_BUILD_DATE', 'unknown'),
      commit_id: ENV.fetch('APP_GIT_COMMIT', 'unknown'),
      build_tag: ENV.fetch('APP_BUILD_TAG', 'unknown')
    }
  end

end
