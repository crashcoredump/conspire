# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/conspire.rb'

Hoe.new('conspire', Conspire::VERSION) do |p|
  p.developer('Phil Hagelberg', 'technomancy@gmail.com')

  p.extra_deps << ['gitjour', '6.3.0']
  p.extra_deps << 'clip'
end

desc "Code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

# vim: syntax=Ruby
