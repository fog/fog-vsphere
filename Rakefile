require 'bundler/gem_tasks'
require 'rubocop/rake_task'

desc 'Run Ruby style checks'
RuboCop::RakeTask.new(:style)

mock = ENV['FOG_MOCK'] || 'true'
task :test do
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

task(default: [:test])
