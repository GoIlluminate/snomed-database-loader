require 'standalone_migrations'
require 'yaml'
require 'zip'
require 'rbconfig'

@os = RbConfig::CONFIG['host_os']

# configurations for SNOMED CT import
configs = {
  # the location of the SNOMED release archive in the Docker container
  docker_release_path: "/scripts/snomed/SnomedCT.zip",
  local_release_path: nil,
  module_name: nil,
  release_type: nil,
  db_name: nil,
  db_host: nil,
  db_port: nil,
  db_username: nil,
  db_password: nil
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
    abort("\n" + message + "\n\nTry 'rake config_help' for more information.\n")
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

task :default => [:postgres_build, :postgres_run]

task :config_help do
  # TODO: please please please keep this usage line updated if anything ever changes
  puts "Usage: rake CONFIG_ENV_VARS"
  puts ""
  puts "Create and populate a PostgreSQL database with a SNOMED CT terminology release."
  puts ""
  puts ""
  puts "== Configurations (required) =="
  puts ""
  puts "SNOMED CT release configurations:"
  puts "  release_path=PATH           The path to the SNOMED CT release archive"
  puts "  module_name=MODULE_NAME     The name of the SNOMED module"
  puts "  release_type=TYPE           The type of the SNOMED release (DELTA, SNAP, FULL, or ALL)"
  puts ""
  puts "Database configurations:"
  puts "  db_name=DBNAME              The database name to connect to"
  puts "  db_host=HOSTNAME            The database server host or socket directory"
  puts "  db_port=PORT                The database server port"
  puts "  db_username=USERNAME        The database user name"
  puts "  db_password=PASSWORD        The database password"
end

task :get_configurations do |task_name|
  # environment variables are deleted afterwards so you have to explicitly set them every time
  configs[:local_release_path] = ENV['release_path']
  ENV['release_path'] = nil

  configs[:module_name] = ENV['module_name']
  ENV['module_name'] = nil

  configs[:release_type] = ENV['release_type']
  ENV['release_type'] = nil

  configs[:db_name] = ENV['db_name']
  ENV['db_name'] = nil

  configs[:db_host] = ENV['db_host']
  ENV['db_host'] = nil

  configs[:db_port] = ENV['db_port']
  ENV['db_port'] = nil

  configs[:db_username] = ENV['db_username']
  ENV['db_username'] = nil

  configs[:db_password] = ENV['db_password']
  ENV['db_password'] = nil

  validate_configurations(configs, task_name)
end

task :postgres_build => [:get_configurations] do 
    sh("#{docker_command} build -t snomedps:latest --build-arg local_release_path=#{configs[:local_release_path]} --build-arg docker_release_path=#{configs[:docker_release_path]} .")
end

task :postgres_run => [:get_configurations] do
    containerID = `#{docker_command} ps -a -q -f name=snomedps`

    # eliminate the container with extreme prejudice if it's already running
    if containerID != ""
      puts("SNOMED database container already running! Stopping...")
      sh("#{docker_command} stop")
      sh("#{docker_command} rm snomedps;")
    end

    sh("#{docker_command} run --name snomedps -d -e POSTGRES_USER=#{configs[:db_username]} -e POSTGRES_PASS=#{configs[:db_password]} -e POSTGRES_DB=#{configs[:db_name]} -p #{configs[:db_port]}:5432 snomedps")
    sh("#{docker_command} exec snomedps ../scripts/load_release-postgresql.sh -l #{configs[:docker_release_path]} -m #{configs[:module_name]} -t #{configs[:release_type]} -d #{configs[:db_name]} -h #{configs[:db_host]} -p #{configs[:db_port]} -u #{configs[:db_username]}")
end
