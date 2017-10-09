source 'https://rubygems.org'

group :development do
  vagrant_opts = {
    git:    'https://github.com/hashicorp/vagrant.git',
    branch: 'master'
  }

  if ENV.key?('VER_VAGRANT') && ENV['VER_VAGRANT'] != 'master'
    vagrant_opts.delete(:branch)

    vagrant_opts['tag'] = "v#{ENV['VER_VAGRANT']}"
  end

  gem 'vagrant', vagrant_opts
end

group :plugins do
  gemspec
end
