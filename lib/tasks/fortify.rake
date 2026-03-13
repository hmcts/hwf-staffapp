# rubocop:disable Layout/LineLength
namespace :fortify_scan do
  desc 'Package and upload to Fortify on Demand'
  task run: :environment do
    require 'fileutils'

    # Check for Java and install if necessary
    puts "Checking for Java..."
    unless system("java -version > /dev/null 2>&1")
      puts "Java not found. Installing OpenJDK..."
      if system("which brew > /dev/null 2>&1")
        system("brew install openjdk@21") || raise("Failed to install Java via Homebrew")
        # Set up the symlink for the system Java wrappers
        system("sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk") if system("test -d /opt/homebrew/opt/openjdk@21")
      else
        raise("Java is not installed and Homebrew is not available. Please install Java manually.")
      end
    end
    puts "Java is available"

    puts "Downloading FoD Uploader..."
    uploader_url = "https://github.com/fod-dev/fod-uploader-java/releases/download/v5.4.3/FodUpload.jar"
    system("curl -L -f -o FodUpload.jar #{uploader_url}") || raise("Failed to download FoD uploader")

    # Verify the JAR file was downloaded correctly
    unless File.exist?('FodUpload.jar') && File.size('FodUpload.jar') > 1000
      raise("Downloaded FodUpload.jar appears to be invalid (size: #{File.size('FodUpload.jar')} bytes)")
    end

    puts "Packaging source code..."
    # Exclude unnecessary files
    system("zip -r source.zip . -x '*.git*' -x 'vendor/*' -x 'node_modules/*' -x '*.jar' -x 'tmp/*' -x 'log/*'") || raise("Failed to package source")

    puts "Uploading to Fortify on Demand..."
    fod_username = 'petr.zaparka@hmcts.net'
    fod_pat = ENV['FORTIFY_PASSWORD'] || raise("FORTIFY_PASSWORD not set")
    fod_tenant = 'mojuk'
    fod_release_id = ENV['FORTIFY_USER_NAME'] || raise("FORTIFY_USER_NAME not set")

    upload_cmd = [
      "java -jar FodUpload.jar",
      "-portalurl https://emea.fortify.com/",
      "-apiurl https://api.emea.fortify.com/",
      "-technologyStackId 17",
      "-uc #{fod_username} #{fod_pat}",
      "-tc #{fod_tenant}",
      "-rid #{fod_release_id}",
      "-z source.zip",
      "-ep SubscriptionOnly"
    ].join(" ")

    system(upload_cmd) || raise("Failed to upload to FoD")

    puts "Successfully uploaded to Fortify on Demand"

    # Cleanup
    FileUtils.rm_f(['FodUpload.jar', 'source.zip'])
  end
end

desc 'Fortify scan'
task :fortify_scan => 'fortify_scan:run'

# rubocop:enable Layout/LineLength
