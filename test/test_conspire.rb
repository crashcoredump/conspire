require 'rubygems'
begin
  gem 'miniunit' # just fer kicks...
rescue LoadError; end

require 'test/unit'
require 'ostruct'
require File.dirname(__FILE__) + '/../lib/conspire'

REMOTE_SPACE = File.dirname(__FILE__) + '/remote-space'
LOCAL_SPACE = File.dirname(__FILE__) + '/local-space'

module Conspire
  def self.reset!
    @conspirators = []
    @thread && @thread.kill
  end

  def self.conspirators; @conspirators end
end

class TestConspire < Test::Unit::TestCase
  def setup
    Gitjour::Application.init(REMOTE_SPACE)
    File.open(REMOTE_SPACE + '/file', 'w') { |f| f.puts "hello world." }
    `cd #{REMOTE_SPACE}; git add file; git commit -m "init"`

    @remote_thread = Thread.new do
      Gitjour::Application.serve(REMOTE_SPACE, 'conspiracy-remote-test', 7458)
    end

    Conspire.start(LOCAL_SPACE, OpenStruct.new(:port => 7457))
    File.open(LOCAL_SPACE + '/file2', 'w') { |f| f.puts "hello world!" }
    `cd #{LOCAL_SPACE}; git add file2; git commit -m "conspire"`
  end

  def teardown
    @remote_thread.kill
    `killall git-daemon` # workaround until gitjour handles this correctly
    Conspire.reset!
    FileUtils.rm_rf(REMOTE_SPACE)
    FileUtils.rm_rf(LOCAL_SPACE)
  end

  def test_start
    assert File.exist?(LOCAL_SPACE + '/.git')
    assert(system("cd #{LOCAL_SPACE} && git pull --rebase git://localhost:7458/"),
           "Could not rebase from remote.")
  end

  def test_discover
    Conspire.discover 1
    assert_equal [7458], Conspire.conspirators.map{ |c| c.port }
  end

  def test_sync
    Conspire.conspirators << Conspire::Conspirator.new('localhost.', '7458')
    Conspire.sync_all

    assert Conspire.conspirators.last, "Dropped remote conspirator"
    assert_equal 'localhost', Conspire.conspirators.last.host
    assert_equal ["#{LOCAL_SPACE}/file"], Dir.glob("#{LOCAL_SPACE}/*")
  end

  def test_conspirator_set
    Conspire.conspirators << Conspire::Conspirator.new('dynabook.', '7458')
    Conspire.conspirators << Conspire::Conspirator.new('dynabook.', '7458')
    assert_equal 1, Conspire.conspirators.size
  end
end
