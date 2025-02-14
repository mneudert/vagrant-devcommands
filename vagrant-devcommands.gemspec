# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vagrant/devcommands/synopsis'
require 'vagrant/devcommands/version'

Gem::Specification.new do |spec|
  spec.name     = 'vagrant-devcommands'
  spec.version  = VagrantPlugins::DevCommands::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ['Marc Neudert']
  spec.email    = ['marc.neudert@gmail.com']

  spec.required_ruby_version     = '>= 3.0', '< 3.4'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.summary     = VagrantPlugins::DevCommands::SYNOPSIS
  spec.description = 'Vagrant plugin to run commands specified ' \
                     'in a Commandfile inside one of your Vagrant boxes'
  spec.homepage    = 'https://github.com/mneudert/vagrant-devcommands'
  spec.license     = 'MIT'

  spec.files  = Dir.glob('lib/**/*')
  spec.files += Dir.glob('locales/**/*')
  spec.files += %w[CHANGELOG.md LICENSE.txt README.md]

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org' if spec.respond_to?(:metadata)
  spec.metadata['rubygems_mfa_required'] = 'true'
end
