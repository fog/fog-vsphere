require 'bundler/gem_tasks'
# require 'rake/testtask'

# Rake::TestTask.new do |t|
#   t.libs << 'spec/'
#   t.test_files = Rake::FileList['spec/**/*_spec.rb']
#   t.verbose = true
# end

mock = ENV['FOG_MOCK'] || 'true'
task :test do
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

task(:default => [:test])
