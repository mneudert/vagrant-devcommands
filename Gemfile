# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  vagrant_opts = {
    git: 'https://github.com/hashicorp/vagrant.git',
    branch: 'main'
  }

  if ENV.key?('VER_VAGRANT') && ENV['VER_VAGRANT'] != 'main'
    vagrant_opts.delete(:branch)

    vagrant_opts['tag'] = "v#{ENV.fetch('VER_VAGRANT', nil)}"
  end

  gem 'vagrant', vagrant_opts

  gem 'coveralls', '~> 0.8'
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.66.0'
  gem 'rubocop-performance', '~> 1.22.0', require: false
end

group :plugins do
  gemspec
end
