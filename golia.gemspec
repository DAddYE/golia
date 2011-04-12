Gem::Specification.new do |s|
  s.name = "golia"
  s.rubyforge_project = "golia"
  s.authors = ["DAddYE"]
  s.email = "d.dagostino@lipsiasoft.com"
  s.summary = "Dead Links Checker and Speed Analyzer"
  s.homepage = "http://www.padrinorb.com"
  s.description = "Golia is an website performance analyzer. Check speed and dead links."
  s.default_executable = "golia"
  s.executables = ["golia"]
  s.version = "1.2.2"
  s.date = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files = %w(README.rdoc Rakefile golia.gemspec) + Dir["lib/**/*"]
end