require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'coveralls/rake/task'
Coveralls::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:spec, 'coveralls:push', :rubocop]
