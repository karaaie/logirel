require 'logirel/initer'
require 'logirel/version'
require 'logirel/q_model'
require 'uuid'
require 'thor'
require 'FileUtils'

module Logirel
 class CLI < Thor
    
	desc "init", "Convert the current folder's projects (src) into a rake+albacore build"
	def init(root_dir = Dir.pwd)
      
      puts "Logirel version #{Logirel::VERSION}"
	  curr = Dir.pwd
      
      puts ""
      puts "Directories Selection"
      puts "---------------------"
	  
      dir = StrQ.new("Specify src directory (#{Initer.new('./src').parse_folders.inspect})", 
	    "./src",
		lambda { |dir| !dir.empty? && Dir.exists?(dir) }).exec
      
      buildscripts = StrQ.new("Buildscripts Directory", "./buildscripts").exec
	  tools = StrQ.new("Tools Directory", "./tools").exec
	  
	  puts "initing semver in folder above #{dir}"
	  Dir.chdir File.join(dir, "..")
	  sh "semver init" do |ok, err|
	    ok || (raise "failed to initialize semver")
	  end
	  Dir.chdir curr
      
      puts ""
      puts "Project Selection"
      puts "-----------------"
      
      selected_projs = Initer.new(dir).parse_folders.
        map { |f| 
          BoolQ.new(f, File.basename(f)).exec # TODO: return bool
        }
      
      puts ""
      puts "Project Meta-Data Definitions"
      puts "-----------------------------"
      
      metas = selected_projs.map do |p|
        
        base = File.basename(p)
        p_dir = File.join(dir, base)
        
        {
          :dir => p_dir,
      	  :title => StrQ.new("Title", base).exec,
      	  :test_dir => StrQ.new("Test Directory", base + ".Tests").exec,
      	  :description => StrQ.new("Description", "#{base} at commit #{`git log --pretty-format=%H`}").exec,
      	  :copyright => StrQ.new("Copyright").exec,
      	  :authors => StrQ.new("Authors").exec,
      	  :company => StrQ.new("Company").exec,
      	  :nuget_key => StrQ.new("NuGet key", base).exec,
      	  :ruby_key => StrQ.new("Ruby key (e.g. 'autotx')").exec,
      	  :guid => UUID.new
        }
      end
      
	  Initer.init_project_details(buildscripts, metas)
      
      # TODO: paths
  	
      # TODO: Create rakefile!
      
      # TODO: tasks in rakefile.rb
    end
  end
end