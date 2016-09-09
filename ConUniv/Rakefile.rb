require './RakeDotNet/command_shell.rb'
require './RakeDotNet/web_deploy.rb'
require './RakeDotNet/iis_express.rb'
require './RakeDotNet/sln_builder.rb'
require './RakeDotNet/file_sync.rb'
require 'net/http'
require 'yaml'
require './scaffold.rb'
require 'jasmine'
require 'uri'
require 'rubygems'
require 'zip'
require 'colorize'
#require 'fileutils'
load 'jasmine/tasks/jasmine.rake'



task :rake_dot_net_initialize do
  #throw error if we are not in the root of the folder
  raise "You are not in the root folder of a RAW Framework Core project!!" if not File.exist?('dev.yml')
  yml = YAML::load File.open("dev.yml")
  @website_port = yml["website_port"]
  @website_deploy_directory = yml["website_deploy_directory"]
  @website_port_load_balanced_1 = yml["website_port_load_balanced_1"]
  @website_deploy_directory_load_balanced_1 = yml["website_deploy_directory_load_balanced_1"]
  @website_port_load_balanced_2 = yml["website_port_load_balanced_2"]
  @website_deploy_directory_load_balanced_2 = yml["website_deploy_directory_load_balanced_2"]
  @solution_name = "#{ yml["solution_name"] }.sln"
  @solution_name_sans_extension = "#{ yml["solution_name"] }"
  @mvc_project_directory = yml["mvc_project"]
  @database_name = yml["database_name"]
  @project_name = yml["solution_name"]
  @iis_express = IISExpress.new
  @iis_express.execution_path = yml["iis_express"]
  @web_deploy = WebDeploy.new

  @test_project = yml["test_project"]
  @test_dll = "./#{ yml["test_project"] }/bin/debug/#{ yml["test_project"] }.dll "

  @test_runner_path = yml["test_runner"]
  @test_runner_command = "#{ yml["test_runner"] } #{ @test_dll }"

  @sh = CommandShell.new
  @sln = SlnBuilder.new
  @file_sync = FileSync.new
  @file_sync.source = @mvc_project_directory
  @file_sync.destination = @website_deploy_directory
  @sln.msbuild_path = "C:\\Program Files (x86)\\MSBuild\\12.0\\bin\\amd64\\msbuild.exe"
  #build?
end

desc "builds and deploys website to directories iis express will use to run app"
task :default => [:build]

desc "creates a new app, downloads the template from github and initialize the app"
task :new  do
  #ask for appName
  puts "Enter app name(case sensitive):".colorize(:cyan)
  appname = STDIN.gets.chomp
  filename = "#{appname}/#{appname}.zip"
  #create the folder
  Dir.mkdir appname
  puts "Downloading template......".colorize(:light_green)
  #for now the template is hosted on the github public pages
  Net::HTTP.start("rawframework.github.io") do |http|
    resp = http.get("/RawTemplate/rawcore.zip")
    open(filename, "wb") do |file|
        file.write(resp.body)
    end
  end
  puts "Inflating template......".colorize(:light_green)
  Zip::File.open(filename) do |zip_file|
  
  toRepalce = 'ConUniv'
  # Handle entries one by one
  zip_file.each do |entry|
      unzipped =entry.name.gsub(toRepalce,appname)
      entry.extract("#{appname}/#{unzipped}")
      if !(unzipped.include? ".dll") && entry.size >0 then
          # load the file as a string
        data = File.read("#{appname}/#{unzipped}") 
        # globally substitute "install" for "latest"
        filtered_data = data.gsub(toRepalce,appname) 
        # open the file for writing
        File.open("#{appname}/#{unzipped}", "w") do |f|
          f.write(filtered_data)
        end
      end
      
    end
  end
  #at this point the zip file has been downloaded, uncompress and delete it
  puts "Get app packages......".colorize(:light_green)
  sh "dotnet restore #{appname}/#{appname}/project.json"
  puts "Building......".colorize(:light_green)
  sh "dotnet build #{appname}/#{appname}/project.json"
  puts "Done!".colorize(:light_blue)
  puts "Type rawf help for a tutorial and options".colorize(:ligh_yellow)
  #delete the zip file
  File.delete filename
end

desc "builds the solution"
task :build => :rake_dot_net_initialize do
  #get packages
  sh "dotnet restore #{@project_name}/project.json"
  #run the app
  sh "dotnet build #{@project_name}/project.json" 
end

desc "run the application"
task :run => :rake_dot_net_initialize do
  sh "dotnet run --project #{@project_name}/project.json" 
end



desc "Show help"
task :help do
  sh "start help\\index.html"
end



desc "run fuzz test using gremlins.js, optionally you can pass the next parameters: controller, view and id. rake gremlins[user,edit,5]"
task :gremlins, :controller, :view, :id do |t, args|
  controller = args[:controller] || "home"
  view = args[:view] ? "\\#{args[:view]}" : ""
  id = args[:id] ? "\\#{args[:id]}" : ""

  sh "start http:\\localhost:3000\\#{controller + view + id}?gremlins=true"
end