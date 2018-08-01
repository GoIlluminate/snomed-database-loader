require 'standalone_migrations'
require 'yaml'
require 'zip'
require 'rbconfig'

@os = RbConfig::CONFIG['host_os']

def docker_command
    if @os.downcase.include?('linux')
        return "sudo docker"
    else
        return "docker"
    end
end

task :postgres_build do 
    sh("#{docker_command} build -t snomedps:latest .")
end

task :postgres_run do
    containerID = `#{docker_command} ps -a -q -f name=snomedps`
    if containerID != ""
        sh("#{docker_command} stop $(#{docker_command} ps -a -q -f name=snomedps) && #{docker_command} rm $(#{docker_command} ps -a -q -f name=snomedps);")
    end
    sh("#{docker_command} run --name snomedps -d -e POSTGRES_USER=postgres -e POSTGRES_PASS=illuminatedb -e POSTGRES_DATABASE=illuminate_db -p 5432:5432 snomedps")
    sh("#{docker_command} exec snomedps ../scripts/load_release-postgresql.sh -l ../snomed/SnomedCT.zip -m US1000124 -t FULL -d postgres -h localhost -p 5432 -u postgres")
end