# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "assign_by_parts/version"

Gem::Specification.new do |s|
  s.name        = "assign_by_parts"
  s.version     = AssignByParts::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Long"]
  s.email       = ["asceth@gmail.com"]
  s.homepage    = "http://github.com/asceth/assign_by_parts"
  s.summary     = "Making partial attribute assigning easier"
  s.description = "A gem for making fields that need partial value assignments easier"

  s.rubyforge_project = "assign_by_parts"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "i18n"

  s.add_development_dependency "rspec", "~>2.0.0"
  s.add_development_dependency "rr"
end
