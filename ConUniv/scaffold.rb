begin
	require 'nokogiri'
	require 'rake'
	require 'fileutils'
	Dir[File.dirname(__FILE__) + '/templates/*.rb'].each {|file| require file }
rescue LoadError
	puts "============ note ============="
	puts "Looks like you don't have nokogiri installed. Nokogiri is used to help you quickly scaffold models, view and controllers:" 
	puts "You *DO NOT* need scaffolding for the Oak interactive tutorial, or any development (just a nice to have)"
	puts "So don't worry about this note if you don't want scaffolding"
	puts "Instructions for setting up nokogiri (one time):"
	puts "  - Install chocolatey by running the powershell script located at chocolatey.org" 
	puts "  - After chocolatey is installed, run the command: cinst ruby.devkit (if you haven't installed ruby's DevKit)" 
	puts "  - Then run the command 'gem install nokogiri'"
	puts "  - Type 'rake -D gen' for more information on scaffolding (the source located in scaffold.rb)."
	puts "================================"
	puts ""
end

namespace :gen do
	desc "creates models for each table in the data base, example: rake gen:fullDbModels"
	task :full_db_models, [] => :rake_dot_net_initialize do |t, args|
		system("cd XmlGenerator&dotnet Generator.dll Model fulldb #{@mvc_project_directory}")
		FileUtils.mv Dir.glob('XmlGenerator/*.xml'), "."
		Dir.glob('*.xml') do |xml_file|
		  file_name = File.basename(xml_file, File.extname(xml_file))
			Rake::Task['gen:model'].invoke(file_name)
			Rake::Task['gen:model'].reenable
		end

	end

	desc "creates an xml file from a dll model, example: rake gen:new_xml_file[User]"
	task :create_xml_file, [:model] => :rake_dot_net_initialize do |t, args|
	  raise "name parameter required, example: rake gen:api[User]" if args[:model].nil?
		model_name = args[:model]
		file_name = model_name.ext("xml")

		system("cd XmlGenerator&dotnet Generator.dll Views #{model_name} #{@mvc_project_directory}")
		FileUtils.mv Dir.glob('XmlGenerator/*.xml'), "."
	end

	desc "Adds a new model from an xml, example: rake gen:model[User]"
	task :model, [:model] => [:rake_dot_net_initialize] do |t, args|
		raise "name parameter required, example: rake gen:model[User]" if args[:model].nil?
		model_name = args[:model]
		file_name = model_name.ext("xml")

		verify_file_name file_name

		system("cd XmlGenerator&dotnet Generator.dll Model #{model_name} #{@mvc_project_directory}")
		FileUtils.mv Dir.glob('XmlGenerator/*.xml'), "."
 		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
		nkg_xml_model.xpath("//entity").each do |model|
			create_model_template model
 		end
 		xml_file.close	
 		File.delete(file_name)	
	end	

	desc "Adds a new api controller, example: rake gen:api[User]"
	task :api, [:model] => [:build, :create_xml_file] do |t, args|
		raise "name parameter required, example: rake gen:api[User]" if args[:model].nil?
		model_name = args[:model]
		file_name = model_name.ext("xml")

		verify_file_name file_name

 		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
 		main_model = nkg_xml_model.xpath("//entity").first
		name = main_model['name']
 		primaryKeyType = main_model['primaryKeyType']
 		root_namespace = nkg_xml_model.xpath("//model").first['namespace']
 		entityNameSpace = main_model['namespace']
		root_namespace = (root_namespace.nil? || root_namespace == entityNameSpace) ? '' : "using #{root_namespace};" 

		create_api_controller_template main_model, primaryKeyType, entityNameSpace, root_namespace

		xml_file.close
		File.delete(file_name)	
	end	

	desc "Adds a new controller, example: rake gen:controller[User]"
	task :controller, [:model] => [:build, :create_xml_file] do |t, args|
		raise "name parameter required, example: rake gen:controller[User]" if args[:model].nil?
		model_name = args[:model]
		file_name = model_name.ext("xml")

		verify_file_name file_name

 		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
 		main_model = nkg_xml_model.xpath("//entity").first
		name = main_model['name']
 		primaryKeyType = main_model['primaryKeyType']
		root_namespace = nkg_xml_model.xpath("//model").first['namespace']
 		entityNameSpace = main_model['namespace']
		root_namespace = (root_namespace.nil? || root_namespace == entityNameSpace) ? '' : "using #{root_namespace};" 

		create_controller_template main_model, primaryKeyType, entityNameSpace,root_namespace
	end	

	desc "Adds a new repository, example: rake gen:repository[User]"
	task :repository, [:model] => [:build, :create_xml_file] do |t, args|
		raise "name parameter required, example: rake gen:repository[User]" if args[:model].nil?
		model_name = args[:model]
		file_name = model_name.ext("xml")

		verify_file_name file_name

 		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
 		main_model = nkg_xml_model.xpath("//entity").first
		name = main_model['name']
 		primaryKeyType = main_model['primaryKeyType']
 		root_namespace = nkg_xml_model.xpath("//model").first['namespace']
 		entityNameSpace = main_model['namespace']
		root_namespace = (root_namespace.nil? || root_namespace == entityNameSpace) ? '' : "using #{root_namespace};" 

		create_repository_template name, primaryKeyType, entityNameSpace
	end	

	desc "Adds a new view, you can choose to use bs_grid plug in for index view with a optional third parameter <true>, 
	example: rake gen:view[Entity,<Edit, Create, Details, Index>,<true>]. \nTo create partial views set a extra parameter 
	partial=true, example: rake gen:view[User,Edit] partial=true"
	task :view, [:model, :type, :use_bs_grid] => [:build, :create_xml_file] do |t, args|
		raise "name and view type parameters are required, example: rake gen:view[Edit,User]" if args[:model].nil? || args[:type].nil?
		@use_partial_views = ENV["partial"] == "true"

		type = args[:type].downcase
		model_name = args[:model]
		use_bs_grid = args[:use_bs_grid]
		file_name = model_name.ext("xml")

		verify_file_name file_name

 		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
 		model = nkg_xml_model.xpath("//entity").first
		name = model['name']

 		folder "Views/#{name}"

		case type
		when "create"
			save view_create_template(model), "#{@mvc_project_directory}/Views/#{name}/Create.cshtml"
			add_cshtml_node name, "Create"
		when "edit"
			save view_edit_template(model), "#{@mvc_project_directory}/Views/#{name}/Edit.cshtml"
			add_cshtml_node name, "Edit"
		when "details"
			save view_details_template(model), "#{@mvc_project_directory}/Views/#{name}/Details.cshtml"
			add_cshtml_node name, "Details"
		when "index"
			puts use_bs_grid
			if use_bs_grid
				create_js_bs_grid_template model
			end

			save view_index_template(model, use_bs_grid), "#{@mvc_project_directory}/Views/#{name}/Index.cshtml"
			add_cshtml_node name, "Index"
		else
			puts "View type is not valid."	
		end
	end	


	desc "adds a CRUD scaffold, example: rake gen:crudFor[Entity]. \nTo create partial views set a extra parameter partial=true, example: rake gen:crudFor[Entity] partial=true"
	task :crudFor, [:model] => [:build, :create_xml_file] do |t, args|
		raise "name parameter required, example: rake gen:crudFor[User]" if args[:model].nil?
		@use_partial_views = ENV["partial"] == "true"

		model_name = args[:model]
		file_name = model_name.ext("xml")

		verify_file_name file_name

		xml_file = File.open(file_name)
 		nkg_xml_model = Nokogiri::XML(xml_file)
		
 		@is_view_model = nkg_xml_model.xpath("//entity").length > 1
 		
 		main_model = nkg_xml_model.xpath("//entity").first
		name = main_model['name']
 		primaryKeyType = main_model['primaryKeyType']
 		root_namespace = nkg_xml_model.xpath("//model").first['namespace']
 		entityNameSpace = main_model['namespace']
		root_namespace = (root_namespace.nil? || root_namespace == entityNameSpace) || root_namespace =='' || root_namespace.nil?  ? '' : "using #{root_namespace};" 

		create_repository_template name, primaryKeyType, entityNameSpace
		
		create_controller_template main_model, primaryKeyType, entityNameSpace, root_namespace

		create_views_templates main_model

  		create_js_templates main_model	

		xml_file.close
		#Delete the xml
		File.delete(file_name)	
		
		puts "Process completed!!"
		
	end

	desc "adds javascript file to your mvc project, example: rake gen:script[index]"
	task :script, [:name] => :build do |t, args|
		raise "js name required, example: rake gen:script[index]" if args[:name].nil?

		verify_file_name args[:name]

		folder "Scripts/app"

		save js_template(args[:name]), "#{@mvc_project_directory}/Scripts/app/#{args[:name]}.js"

		add_js_node args[:name]
	end

	def save content, file_path
		write_file = false
		if !File.exists?(file_path) || @overwrite_files
			write_file = true
		elsif @overwrite_files == nil 
			puts "Some files already exists, do you want replace all? (Y/N)" 
			@overwrite_files = (STDIN.gets.chomp == 'y')
			write_file = @overwrite_files
		end

		if write_file
			File.open(file_path, "w+") { |f| f.write(content) }
			puts "#{file_path} added"
		else
			puts "#{file_path} skipped"
		end
	end

	def folder dir
		FileUtils.mkdir_p "./#{@mvc_project_directory}/#{dir}/"
	end

	def add_compile_node folder, name, project = nil
		#this is no logner needed for dotnet core projects
		#to_open = project || proj_file
		#doc = Nokogiri::XML(open(to_open))
		#if folder == :root
		#	add_include doc, :Compile, "#{name}.cs"
		#else
		#	add_include doc, :Compile, "#{folder.to_s}\\#{name}.cs"
		#end
		#File.open(to_open, "w") { |f| f.write(doc) }
	end

	def add_cshtml_node folder, name
		#this is no logner needed for dotnet core projects
		#doc = Nokogiri::XML(open(proj_file))
		#add_include doc, :Content, "Views\\#{folder}\\#{name}.cshtml"
		#File.open(proj_file, "w") { |f| f.write(doc) }
	end
	
	def add_js_node name
		#this is no logner needed for dotnet core projects
		#doc = Nokogiri::XML(open(proj_file))
		#add_include doc, :Content, "Scripts\\app\\#{name}.js"
		#File.open(proj_file, "w") { |f| f.write(doc) }
	end

	def add_include doc, type, value
		#this is no logner needed for dotnet core projects
		#if doc.xpath("//xmlns:#{type.to_s}[@Include='#{value}']").length == 0
		#	doc.xpath("//xmlns:ItemGroup[xmlns:#{type.to_s}]").first << "<#{type.to_s} Include=\"#{value}\" />"
		#end
	end

	def proj_file
		"#{@mvc_project_directory}/#{@mvc_project_directory}.csproj"
	end

	def proj_tests_file
		"#{@test_project}/#{@test_project}.csproj"
	end

	def webconfig_file
		"#{@mvc_project_directory}/Web.config"
	end

	def verify_file_name name
		raise "You cant use #{name} as the name. No spaces or fancy characters please." if name =~ /[\x00\/\\:\*\?\"<>\|]/ || name =~ / /
	end

	def add_db_connection_string
		doc = Nokogiri::XML(open(webconfig_file))
		doc.xpath("//connectionStrings").first << "<add name='Default' providerName='System.Data.SqlClient' connectionString='Data Source=localhost\\SQLEXPRESS;Initial Catalog=#{@database_name};Persist Security Info=true;User ID=user_name;Password=Password1234' />"
		File.open(webconfig_file, "w") { |f| f.write(doc) }
	end

	def create_repository_template name, keytype, entityNameSpace
		folder "Repositories"
		repository_name = name + "Repository"
		save repository_template(name, keytype,entityNameSpace), "#{@mvc_project_directory}/Repositories/#{repository_name}.cs"
		add_compile_node :Repositories, repository_name
	end

	def create_model_template model
		model_name = model['name']
		save model_template(model), "#{@mvc_project_directory}/Models/#{model_name}.cs"
		add_compile_node :Models, model_name
	end

	def create_controller_template model, keytype, entityNameSpace, root_namespace
		controller_name = model['name'] + "Controller"
		save controller_template(model, keytype, entityNameSpace, root_namespace), "#{@mvc_project_directory}/Controllers/#{controller_name}.cs"
		add_compile_node :Controllers, controller_name
	end

	def create_api_controller_template model, keytype, entityNameSpace, root_namespace
		api_controller_name = model['name'] + "Controller"
		folder "Controllers/Api"

		save api_controller_template(model, keytype, entityNameSpace, root_namespace), "#{@mvc_project_directory}/Controllers/Api/#{api_controller_name}.cs"
		add_compile_node "Controllers\\Api", api_controller_name
	end
	
	def create_views_templates model
		name = model['name']
		folder "Views/Shared"
		folder "Views/#{name}"

		save view_index_template(model), "#{@mvc_project_directory}/Views/#{name}/Index.cshtml"
		add_cshtml_node name, "Index"

		save view_create_template(model), "#{@mvc_project_directory}/Views/#{name}/Create.cshtml"
		add_cshtml_node name, "Create"

		save view_details_template(model), "#{@mvc_project_directory}/Views/#{name}/Details.cshtml"
		add_cshtml_node name, "Details"

		save view_edit_template(model), "#{@mvc_project_directory}/Views/#{name}/Edit.cshtml"
		add_cshtml_node name, "Edit"

		add_navigation_link name, "List #{name}"
	end

	def create_js_templates model
		name = model['name']
		folder "wwwroot/js/app"

		save js_binding_template(model), "#{@mvc_project_directory}/wwwroot/js/app/#{name}.binding.js"
		add_js_node "#{name}.binding"

		save js_model_validate_template(model), "#{@mvc_project_directory}/wwwroot/js/app/#{name}.validate.js"
		add_js_node "#{name}.validate"

		save js_controller_template(model), "#{@mvc_project_directory}/wwwroot/js/app/#{name}.controller.js"
		add_js_node "#{name}.controller"
	end

	def create_db_context_templates name
		folder "Context"

		save context_template(name), "#{@mvc_project_directory}/Context/#{name}Context.cs"
		add_compile_node :Context, "#{name}Context"	
	end

	def create_tests_controller_template model
		#test project is not implemented yet
		#name = model['name']
		#file_name = "#{name}Controller_spec"
		#save tests_controller_template(model), "#{@test_project}/#{file_name}.cs"
		#add_compile_node :root, file_name, proj_tests_file
	end

	def create_js_bs_grid_template model
		name = model['name']
		folder "Scripts/app"

		save js_bs_grid_template(model), "#{@mvc_project_directory}/wwwroot/js/app/#{name}.grid.js"
		add_js_node "#{name}.grid"
	end


	def add_navigation_link controller_name, display_name
		source = "#{@mvc_project_directory}/Views/Shared/_Layout.cshtml"
		file = File.open(source, "r")
 		
 		content =  file.read.to_s.gsub("<!--toplinks-->", 
 			"<li @if (ViewBag.page == \"#{controller_name}\"){<text> class=\"active\"</text>;}><a href=\"/#{controller_name}\">#{display_name}</a></li>\n<!--toplinks-->")

		File.open(source, "w") do |f| 
			f.write(content)
		end

		file.close		
	end

	#remove the following comments if you are not going to use sidekick
	#Rake::Task["model"].enhance do
	#  Rake::Task["rebuild"].invoke
	#end
	#Rake::Task["crudFor"].enhance do
	#  Rake::Task["rebuild"].invoke
	#end
	#Rake::Task["api"].enhance do
	#  Rake::Task["rebuild"].invoke
	#end
end

