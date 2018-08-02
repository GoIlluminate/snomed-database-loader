require 'optparse'
require 'standalone_migrations'
require 'yaml'
require 'zip'
require 'rbconfig'

@os = RbConfig::CONFIG['host_os']

# configurations for SNOMED CT import
configurations = {
  release_path: nil,
  module_name: nil,
  release_type: nil,
  db_name: nil,
  db_host: nil,
  db_port: nil,
  db_username: nil,
  db_password: nil
};

def docker_command
    if @os.downcase.include?('linux')
        return "sudo docker"
    else
        return "docker"
    end
end

def get_configurations(args, calling_task_name)
  def show_error_message(message, rake_task)
    puts "\n" + message
    puts "\nTry 'rake #{rake_task} --help' for more information."
    # TODO: fix this command - this doesn't actually show the help
  end

  parser = OptionParser.new do|flags|
    flags.banner = "Usage: rake #{calling_task_name} -- ARGS"

    flags.on('-l', '--release-path PATH', 'The path to the SNOMED CT release archive') do |release_path|
      args[:release_path] = release_path;
    end

    flags.on('-m', '--module MODULE_NAME', 'The name of the SNOMED module') do |module_name|
      args[:module_name] = module_name;
    end

    flags.on('-t', '--release-type RELEASE', [:DELTA, :SNAP, :FULL, :ALL], 'The type of the SNOMED release (DELTA, SNAP, FULL, or ALL)') do |release_type|
      args[:release_type] = release_type;
    end

    flags.on('-d', '--dbname DBNAME', 'The database name to connect to') do |db_name|
      args[:db_name] = db_name;
    end

    flags.on('-h', '--host HOSTNAME', 'The database server host or socket directory') do |db_host|
      args[:db_host] = db_host;
    end

    flags.on('-p', '--port PORT', 'The database server port') do |db_port|
      args[:db_port] = db_port;
    end

    flags.on('-u', '--username USERNAME', 'The database user name') do |db_username|
      args[:db_username] = db_username;
    end

    flags.on('-w', '--password PASSWORD', 'The database password') do |db_password|
      args[:db_password] = db_password;
    end

    flags.on('-H', '--help', 'Display this help and exit') do
      puts flags
      exit
    end
  end

  # parse the command-line arguments
  parser.parse

  def find_missing_arguments(args)
    arg_descriptions = {
      db_name: "the database name",
      db_host: "the database server host or socket directory",
      release_path: "the path to the SNOMED archive",
      module_name: "the name of the SNOMED module",
      db_port: "the database server port",
      release_type: "the type of the SNOMED release",
      db_username: "the database user name",
      db_password: "the database password"
    }

    missing_arg_descriptions = []

    # find missing arguments and put their descriptions in the array
    args.each do |key, value|
      if value == nil
        missing_arg_descriptions.push(arg_descriptions[key])
      end
    end

    # return the list of descriptions of missing arguments
    missing_arg_descriptions
  end

  missing_argument_descriptions = find_missing_arguments(args)

  if missing_argument_descriptions.length > 0
    show_error_message "Error: missing necessary configuration option(s)." +
      "\nThe following information was not provided:" +
      missing_argument_descriptions.reduce("") { |list, item| list + "\n - " + item },
      calling_task_name

    abort
  end

  # return the arguments
  args
end

task :default => [:get_configurations, :postgres_build, :postgres_run]

task :get_configurations do |task_name|
  configurations = get_configurations(configurations, task_name)
end

task :postgres_build do 
    sh("#{docker_command} build -t snomedps:latest .")
end

task :postgres_run do
    containerID = `#{docker_command} ps -a -q -f name=snomedps`

    if containerID != ""
        sh("#{docker_command} stop $(#{docker_command} ps -a -q -f name=snomedps) && #{docker_command} rm $(#{docker_command} ps -a -q -f name=snomedps);")
    end

    sh("#{docker_command} run --name snomedps -d -e POSTGRES_USER=#{args[:db_username]} -e POSTGRES_PASS=#{args[:db_password]} -e POSTGRES_DATABASE=#{args[:db_name]} -p 5432:#{args[:db_port]} snomedps")
    sh("#{docker_command} exec snomedps ../scripts/load_release-postgresql.sh -l #{args[:release_path]} -m #{args[:module_name]} -t #{args[:release_type]} -d #{args[:db_name]} -h #{args[:db_host]} -p 5432 -u #{args[:db_username]}")
end
