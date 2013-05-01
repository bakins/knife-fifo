Gem::Specification.new do |s|
  s.name        = "knife-project-fifo"
  s.version     = "0.1.0"
  s.authors     = ["Brian Akins"]
  s.email       = ["brian@akins.org"]
  s.homepage = "https://github.com/bakins/knife-project-fifo"
  s.summary = "Project Fifo Support for Chef's Knife Command"
  s.description = s.summary
  s.license       = "Apache 2.0"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "chef", ">= 0.10.10"
  s.require_paths = ["lib"]
end
