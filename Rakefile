require 'rubygems/specification'
require 'rake/gempackagetask'
require 'rake'

def gemspec
  @gemspec ||= begin
    file = File.expand_path("golia.gemspec")
    ::Gem::Specification.load(file)
  end
end

desc "Validates the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Displays the current version"
task :version do
  puts "Current version: #{gemspec.version}"
end

desc "Release the gem"
task :release => :package do
  sh "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
  sh "rm -rf pkg"
  sh "git add .; git commit -m \"Bump to version #{gemspec.version}\"; git push"
end

desc "Installs the gem locally"
task :install => :package do
  sh "gem install pkg/#{gemspec.name}-#{gemspec.version}"
  sh "rm -rf pkg"
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

task :package => :gemspec