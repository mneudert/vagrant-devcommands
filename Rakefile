require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :style do
  desc 'Run ruby style checks'

  RuboCop::RakeTask.new(:ruby) do |task|
    task.patterns = [
      '**/*.rb',
      '*.gemspec',
      'Gemfile',
      'Rakefile'
    ]
  end
end

namespace :test do
  desc 'Run tests'

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'test/unit/**/*_spec.rb'
  end
end

task default: ['style:ruby', 'test:unit']
task travis: ['test:unit']
