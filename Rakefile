# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'coveralls/rake/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Coveralls::RakeTask.new

namespace :style do
  desc 'Run ruby style checks'
  RuboCop::RakeTask.new(:ruby)
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

task default: ['style:ruby', 'test:unit', 'test:integration']
