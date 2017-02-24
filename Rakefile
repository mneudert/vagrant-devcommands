require 'bundler/gem_tasks'
require 'coveralls/rake/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Coveralls::RakeTask.new

namespace :style do
  desc 'Run ruby style checks'

  RuboCop::RakeTask.new(:ruby) do |task|
    task.patterns = [
      'lib/**/*.rb',
      '*.gemspec',
      'Gemfile',
      'Rakefile'
    ]
  end
end

namespace :test do
  desc 'Run unit tests'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'test/unit/**/*_spec.rb'
  end

  desc 'Run integration tests'
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'test/integration/**/*_spec.rb'
  end
end

namespace :test do
  # travis testing task
  RSpec::Core::RakeTask.new(:travis) do |t|
    t.pattern = 'test/**/*_spec.rb'
  end

  Rake::Task['test:travis'].clear_comments
end

task default: ['style:ruby', 'test:unit', 'test:integration']
task travis: ['style:ruby', 'test:travis']
