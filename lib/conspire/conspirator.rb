module Conspire
  class Conspirator
    attr_accessor :host, :port, :name

    def initialize(host, port, name)
      # host has a trailing dot; remove it
      @host, @port, @name = host[0 .. -2], port, name
    end

    def sync(path)
      # TODO: figure out conflictless rebasing; new content always wins. evan?
      if ENV['DEBUG']
        puts "cd #{path} && git pull --rebase #{url}"
        system "cd #{path} && git pull --rebase #{url}"
      else
        system "cd #{path} && git pull --rebase #{url} &> /dev/null"
      end or raise "could not rebase from #{url}" if ! success
    end

    def url; "git://#{@host}:#{@port}/" end
    alias_method :to_s, :url
    alias_method :inspect, :url

    # For set equality
    def eql?(other); self.url == other.url end
    def hash; url.hash end
  end
end
