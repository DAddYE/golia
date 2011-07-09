Gem::Specification.new do |s|
  s.name               = "golia"
  s.rubyforge_project  = "golia"
  s.authors            = ["DAddYE"]
  s.email              = "d.dagostino@lipsiasoft.com"
  s.summary            = "Dead Links Checker and Speed Analyzer"
  s.homepage           = "http://www.padrinorb.com"
  s.description        = "Golia is an website performance analyzer. Check speed and dead links."
  s.default_executable = "golia"
  s.version            = "1.3.2"
  s.date               = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files   = Dir["*.rdoc"]
  s.files              = `git ls-files`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths      = %w(lib)
end