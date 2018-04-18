require 'bundler/gem_tasks'
require 'rubocop/rake_task'

desc 'Run Ruby style checks'
RuboCop::RakeTask.new(:style)

namespace :travis do
  desc 'Run tests on Travis'
  task ci: %w(style test)
end

mock = ENV['FOG_MOCK'] || 'true'
task :test do
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

task(default: [:test])
