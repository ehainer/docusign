# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docusign/version'

Gem::Specification.new do |spec|
  spec.name          = 'docusign'
  spec.version       = Docusign::VERSION
  spec.authors       = ['Eric Hainer']
  spec.email         = ['eric@commercekitchen.com']

  spec.summary       = %q{Docusign Integration}
  spec.homepage      = 'https://www.github.com/ehainer/docusign'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '~> 5'
  spec.add_dependency 'carrierwave', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 11.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.4'
  spec.add_development_dependency 'factory_girl_rails', '~> 4.7'
  spec.add_development_dependency 'sqlite3', '~> 1'
end
