require 'optparse'
require 'standalone_migrations'
require 'yaml'
require 'zip'
require 'rbconfig'

@os = RbConfig::CONFIG['host_os']

# configurations for SNOMED CT import
configs = {
  # the location of the SNOMED release archive in the Docker container
  docker_release_path: "/snomed/SnomedCT.zip"
}

def docker_command
    if @os.downcase.include?('linux')
        return "sudo docker"
    else
        return "docker"
    end
end

# really just confirms that all of the configuration values are present
def validate_configurations(configurations, calling_task_name)
  def show_error_message(message, task_name)
    abort("\n" + message + "\n\nTry 'rake -- #{task_name} --help' for more information.\n")
  end

  config_descriptions = {
    local_release_path: "the path to the SNOMED archive",
    module_name: "the name of the SNOMED module",
    release_type: "the type of the SNOMED release",
    db_name: "the database name",
    db_host: "the database server host or socket directory",
    db_port: "the database server port",
    db_username: "the database user name",
    db_password: "the database password"
  }

  missing_config_descriptions = []

  # find missing configurations and put their descriptions in the array
  configurations.each do |key, value|
    if value == nil
      missing_config_descriptions.push(config_descriptions[key])
    end
  end

  # show message and exit if any configurations are missing
  if missing_config_descriptions.length > 0
    show_error_message("Error: missing necessary configuration option(s)." +
      "\nThe following information was not provided:" +
      missing_config_descriptions.reduce("") { |list, item| list + "\n - " + item },
      calling_task_name)
  end
end

# TODO: Remove :get_configurations? I want it to run first so we don't bother building if we don't have all the configs, but maybe that's overkill - it's a dependency for postgres_run
task :default => [:get_configurations, :postgres_build, :postgres_run]

task :get_configurations do |task_name|
  parser = OptionParser.new do |flags|
    flags.banner = "Usage: rake -- #{task_name} CONFIGURATIONS"
    flags.separator ""
    flags.separator "Create and populate a PostgreSQL database with a SNOMED CT terminology release."
    flags.separator ""
    flags.separator ""
    flags.separator "== Configurations (required) =="
    flags.separator ""
    flags.separator "SNOMED CT release configurations:"

    configs[:local_release_path] = nil

    flags.on('-l', '--release-path PATH', 'The path to the SNOMED CT release archive') do |release_path|
      configs[:local_release_path] = release_path;
    end

    configs[:module_name] = nil

    flags.on('-m', '--module MODULE_NAME', 'The name of the SNOMED module') do |module_name|
      configs[:module_name] = module_name;
    end

    configs[:release_type] = nil

    flags.on('-t', '--release-type RELEASE', 'The type of the SNOMED release (DELTA, SNAP, FULL, or ALL)') do |release_type|
      configs[:release_type] = release_type;
    end

    flags.separator ""
    flags.separator "Database configurations:"

    configs[:db_name] = nil

    flags.on('-d', '--dbname DBNAME', 'The database name to connect to') do |db_name|
      configs[:db_name] = db_name;
    end

    configs[:db_host] = nil

    flags.on('-h', '--host HOSTNAME', 'The database server host or socket directory') do |db_host|
      configs[:db_host] = db_host;
    end

    configs[:db_port] = nil

    flags.on('-p', '--port PORT', 'The database server port') do |db_port|
      configs[:db_port] = db_port;
    end

    configs[:db_username] = nil

    flags.on('-u', '--username USERNAME', 'The database user name') do |db_username|
      configs[:db_username] = db_username;
    end

    configs[:db_password] = nil

    flags.on('-w', '--password PASSWORD', 'The database password') do |db_password|
      configs[:db_password] = db_password;
    end

    flags.separator ""
    flags.separator ""
    flags.separator "== Other (optional) =="

    flags.on_tail("-H", "--help", "Display this help and exit") do
      puts flags

      exit
    end
  end

  args = parser.order!(ARGV)

  # parse the command-line arguments
  parser.parse!(args)

  validate_configurations(configs, task_name)
end

task :postgres_build do 
    sh("#{docker_command} build -t snomedps:latest --build-arg local_release_path=#{configs[:local_release_path]} --build-arg docker_release_path=#{configs[:docker_release_path]} .")
end

task :postgres_run => [:get_configurations] do
    containerID = `#{docker_command} ps -a -q -f name=snomedps`

    # eliminate the container with extreme prejudice if it's already running
    if containerID != ""
      puts("SNOMED database container already running! Stopping...")
      sh("#{docker_command} stop $(#{docker_command} ps -a -q -f name=snomedps) && #{docker_command} rm $(#{docker_command} ps -a -q -f name=snomedps);")
    end

    sh("#{docker_command} run --name snomedps -d -e POSTGRES_USER=#{configs[:db_username]} -e POSTGRES_PASS=#{configs[:db_password]} -e POSTGRES_DATABASE=#{configs[:db_name]} -p #{configs[:db_port]}:5432 snomedps")
    sh("#{docker_command} exec snomedps ../scripts/load_release-postgresql.sh -l #{configs[:docker_release_path]} -m #{configs[:module_name]} -t #{configs[:release_type]} -d #{configs[:db_name]} -h #{configs[:db_host]} -p #{configs[:db_port]} -u #{configs[:db_username]}")
end
