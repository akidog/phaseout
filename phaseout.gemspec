lib = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'phaseout/version'

Gem::Specification.new do |spec|
  spec.name          = "phaseout"
  spec.version       = Phaseout::VERSION
  spec.authors       = ['Dalton Pinto', 'Felipe JAPM']
  spec.email         = ['dalthon@dlt.local', 'felipe@japm.local']
  spec.summary       = %q{SEO Management for Rails}
  spec.description   = %q{SEO Tags Management for Rails}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir['{bin,lib,test,spec,features}/**/*'] + [ 'phaseout.gemspec', 'LICENSE.txt', 'Rakefile', 'Gemfile', 'README.mdown' ]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  spec.require_paths = ['lib']

  spec.add_development 'redis'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
