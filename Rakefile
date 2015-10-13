require 'bundler/gem_tasks'
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

task default: ['style:ruby']
