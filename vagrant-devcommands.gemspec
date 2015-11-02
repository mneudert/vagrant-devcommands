# coding: utf-8
lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vagrant/devcommands/version'

Gem::Specification.new do |spec|
  spec.name     = 'vagrant-devcommands'
  spec.version  = VagrantPlugins::DevCommands::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ['Marc Neudert']
  spec.email    = ['marc.neudert@gmail.com']

  spec.summary     = 'Runs vagrant commands from a Commandfile'
  spec.description = 'Vagrant plugin to run commands specified'\
                     ' in a Commandfile inside one of your vagrant boxes'
  spec.homepage    = 'https://github.com/mneudert/vagrant-devcommands'
  spec.license     = 'MIT'

  spec.files = Dir.glob('lib/**/*') + %w(CHANGELOG.md LICENSE.txt README.md)

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  end

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rubocop', '~> 0.34'
end
