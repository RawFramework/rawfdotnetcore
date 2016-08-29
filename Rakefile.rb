require './RakeDotNet/command_shell.rb'
require './RakeDotNet/web_deploy.rb'
require './RakeDotNet/iis_express.rb'
require './RakeDotNet/sln_builder.rb'
require './RakeDotNet/file_sync.rb'
require 'net/http'
require 'yaml'
require './scaffold.rb'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'


task :rake_dot_net_initialize do
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
end

desc "builds and deploys website to directories iis express will use to run app"
task :default => [:build, :deploy]


desc "builds the solution"
task :build => :rake_dot_net_initialize do
  @sln.build @solution_name 
end

desc "rebuilds the solution"
task :rebuild => :rake_dot_net_initialize do
  @sln.rebuild @solution_name 
end

desc "creates a new app, downloads the template from github and initialize the app"
task :new, [:appName]   do
  puts "download the template"
  puts "replacing tokens"
  puts "get app packages"
end

desc "deploys MVC app to directory that iis express will use to run"
task :deploy => :rake_dot_net_initialize do 
  @web_deploy.deploy @mvc_project_directory, @website_deploy_directory
end

desc "start iis express for MVC app"
task :server => :rake_dot_net_initialize do
  sh @iis_express.command @website_deploy_directory, @website_port
end

desc "synchronizes a file specfied to the website deployment directory"
task :sync, [:file] => :rake_dot_net_initialize do |t, args|
  @file_sync.sync args[:file]
end

desc "Show help"
task :help do
  sh "start help\\index.html"
end

desc "run nspec tests"
task :tests => :build do
  puts "Could not find the NSpec test runner at location #{ @test_runner_path }, update your dev.yml to point to the correct runner location." if !File.exists? @test_runner_path

  puts "if you have any failures, you can run 'rake stacktrace:tests' for a nice stacktrace visualization"

  sh @test_runner_command if File.exists? @test_runner_path
end

desc "run fuzz test using gremlins.js, optionally you can pass the next parameters: controller, view and id. rake gremlins[user,edit,5]"
task :gremlins, :controller, :view, :id do |t, args|
  controller = args[:controller] || "home"
  view = args[:view] ? "\\#{args[:view]}" : ""
  id = args[:id] ? "\\#{args[:id]}" : ""

  sh "start http:\\localhost:3000\\#{controller + view + id}?gremlins=true"
end