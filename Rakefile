require "bundler/gem_tasks"
require 'rspec/core/rake_task'


desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = '-c'
end

task :default do
  puts <<-STRINGSTRINGSTRING
Run `rake -T' to see a list of all available tasks.
STRINGSTRINGSTRING
end
