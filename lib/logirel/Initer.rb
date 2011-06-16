﻿require 'semver'
require 'enumerator'
require 'net/http'

module Logirel
  class Initer
	
	attr_accessor :root_path, :buildscripts_path
	
	def initialize(root = '.', buildscripts = 'buildscripts'); 
	                @root_path = root
					@buildscripts_path = buildscripts; end
	def set_root(root); @root_path = root; end
  
    def get_commands
	  cmd ||= []
	  cmd << "semver init"
	end
	
	def nuget_from_codeplex(cp_ver, gem_ver)
	  (cp_ver <=> gem_ver) > 0
	end
	
	def create_structure
	  # puts "making dir #{@root_path}"
	  ['buildscripts', 'src'].each do |d|
	    path = File.join(@root_path, d)
	    Dir.mkdir path unless Dir.exists? path
	  end
	end
	
	def create_path_folders(metas, f)
	  	f.puts %q{
require File.dirname(__FILE__) + '/project_data'
root_folder = File.expand_path("#{File.dirname(__FILE__)}/..")
Folders = \{
}
		f.puts ":src => " + StrQ.new("src").exec + ","
		f.puts ":out => " + StrQ.new("build").exec + ","
		f.puts ":package => " + StrQ.new("packages").exec + ","
		f.puts ":tools => " + StrQ.new("tools").exec + ","
		f.puts %q{:tests => File.join("build", "tests"),
:nuget => File.join("build", "nuget"),
:root => root_folder,
:binaries => "placeholder - specify build environment",
}
		f.puts ":#{metas[:ruby_key]}" + " => {"
        f.puts ':nuspec => File.join("build", "nuspec", Projects[' + ":#{metas[:ruby_key]}" + '][' + ":#{metas[:dir]}" + ']),'
        f.puts %q{:out => 'placeholder - specify build environment',
:test_out => 'placeholder - specify build environment'
\},\}}
	end
	
	def create_path_files(metas, f)
	    f.puts "Files = {"
		f.puts ":sln => " + StrQ.new("sln").exec + ","
		f.puts ":#{metas[:ruby_key]} => {"
		f.puts ':nuspec => File.join(Folders[:nuspec], Projects[' + ":#{metas[:ruby_key]}" + '][' + ":#{metas[:id]}" + '].nuspec),'
		f.puts %q{:nunit => File.join(Folders[:nunit], "nunit-console.exe"),
:ilmerge => File.join(Folders[:tools], "ILMerge.exe")
\},\}}
	end
	
	def create_path_commands(metas, f)
	  	f.puts %q{Commands = \{
:nuget => File.join(Folders[:tools], "NuGet.exe")
\}}
	end
	
	def create_path_uris(metas, f)
	  	f.puts %q{Uris = \{
:nuget_offical => "http://packages.nuget.org/v1/"
\}}
	end
	
	def init_paths_rb(metas)
      File.open(File.join(@root_path, @buildscripts_path, "paths.rb"), "w") do |f|
        create_path_folders(metas, f)
		create_path_files(metas, f)
		create_path_commands(metas, f)
		create_path_uris(metas, f)
	  end
	  # File.open(File.join(@root_path, @buildscripts_path, "paths.rb"), "r") do |infile|
        # puts ""
		# puts ""
		# while (line = infile.gets)
          # puts "#{line}"
        # end
	  # end
	end
	
	def init_environement_rb
	  path = File.join(@root_path, @buildscripts_path, "environment.rb")
	  File.open(path, "w") do |f|
	    f.puts Net::HTTP.get(
		  URI.parse('https://raw.github.com/haf/logirel/master/content/environment.rb'))
	  end
	end
	
	def parse_folders
	  src = File.join(@root_path, 'src', '*')
	  Dir.
	    glob(src).
	    keep_if{ |i| 
		  projs = File.join(i, "*.{csproj,vbproj,fsproj}")
		  File.directory? i and Dir.glob(projs).length > 0
		}.
		map{|x| File.basename(x) }
	end
	
	def init_gemfile
	  File.open(File.join(@root_path, "Gemfile"), "w") do |f|
        f.puts 'source "http://rubygems.org"'
        f.puts 'gem "albacore"'
		f.puts 'gem "semver"'
		f.puts 'gem "bundler"'
	  end
	end
	
	def init_utils
	  path = File.join(@root_path, @buildscripts_path, "utils.rb")
	  File.open(path, "w") do |f|
	    f.puts Net::HTTP.get(
		  URI.parse('https://raw.github.com/haf/logirel/master/content/utils.rb'))
	  end
	end
	
	def build_tasks(metas)
	  
	end
	
	def assembly_infos(metas)
	  
	end
	# asm info for every nuget
	def nugets(metas)
	  
	end
	
	def init_rakefile(metas)
	  # puts metas.map{|m| ":build_"+m.ruby_key}
      File.open(File.join(@root_path, @buildscripts_path, "Rakefile.rb"), "w") do |f|
	    f.puts %q{
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require # if rake gets a wee bit too slow, you may remove this
require 'albacore'
require 'semver'
require 'rake/clean'
require '#{buildscripts_path}/project_details'
require '#{buildscripts_path}/paths'
require '#{buildscripts_path}/utils'
require '#{buildscripts_path}/environment'
task :default => [:release]
task :debug => ["env:debug", :build]
task :release => ["env:release", :build]
task :ci => ["env:release", :build, :package]
}
        f.puts "task :build => #{metas[:ruby_key]}"
		
		f.puts build_tasks(metas)
	  end
	end
	
	def init_project_details(metadata)
      File.open(File.join(@root_path, @buildscripts_path, "project_details.rb"), "w") do |f|
	    f.puts "Projects = {"
		# m = ["my key", value]
		# projects[m[0]] = value
	    metadata.keys.each_with_index do |key, index|
		  if index == metadata.length-1
            f.puts ":#{key} = #{p(metadata[key])}"
		  else 
		    f.puts ":#{key} = #{p(metadata[key])},"
		  end
        end
		f.puts "}"
      end
	end
  end
end