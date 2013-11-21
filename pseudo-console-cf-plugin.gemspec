# -*- encoding: utf-8 -*-
# Copyright (c) GoPivotal (UK) Ltd.

Gem::Specification.new do |s|
  s.name         = "pseudo-console-cf-plugin"
  s.version      = '0.0.1'
  s.platform     = Gem::Platform::RUBY
  s.summary      = "CF Pseudo Console"
  s.description  = "CF command line extension to allow pseudo console access to an app container"
  s.author       = "GoPivotal"
  s.homepage      = 'https://github.com/danhigham/pseudo-console-cf-plugin'
  s.license       = 'Apache 2.0'
  s.email         = "support@cloudfoundry.com"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  s.files        = `git ls-files -- lib/*`.split("\n") + %w(README.md)
  s.require_path = "lib"

  s.add_dependency "cf"
  s.add_dependency "faye"
  s.add_dependency "ruby-termios"
end