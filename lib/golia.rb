require 'open-uri'
require 'net/http'
require 'fileutils'
require 'benchmark'
require 'tmpdir'

class Golia
  def initialize(host)
    @host = host
    @host = "http://#{@host}" unless @host =~ /^http/
    @pid  = "#{Dir.tmpdir}/golia-#{@host.gsub(/^http:\/\//, '')}"
    @checked, @links, @invalid, @valid, @long, @ms = [], [], [], [], [], []

    if File.exist?(@pid)
      puts "<= Founded staled pid"
      Process.kill(9, File.read(@pid).to_i) rescue nil
    end

    trap("INT") { puts "<= Golia has ended his set (crowd applauds)"; kill; Process.kill(9, Process.pid) }

    parse!(@host)
  end

  def parse!(url)
    begun_at = Time.now
    response = open(url)
    @ms << Time.now-begun_at
    body  = response.read
    links = body.scan(/<a.+?href=["'](.+?)["']/m).flatten
    links.reject! { |link| link =~ /^\/$|^http|^mailto|^javascript|#/ || File.extname(link) != "" }
    links.map! { |link| link = "/"+link if link !~ /^\//; @host+link }
    @links.concat(links-@checked)
  end

  def kill
    FileUtils.rm_rf(@pid)
  end

  def start!
    loop do
      break if @links.empty?
      @links.each do |link|
        begin
          @checked << link
          parse!(link)
          @valid << link
          @long  << link if @ms.last > 1
          puts "\e[32mValid\e[0m (%0.2fms) %s" % [@ms.last, link]
        rescue Exception => e
          @invalid << link
          puts "\e[31mInvalid\e[0m %s - %s" % [link, e.message]
        ensure
          @links.delete(link)
        end
      end
    end
    puts
    puts "======== SUMMARY ========"
    puts "Valid Links: %d" % @valid.size
    puts "Invalid Links: %d" % @invalid.size
    @invalid.each do |link|
      puts "  #{link}"
    end
    puts "Long requests: %d" % @long.size
    @long.each do |link|
      puts "  #{link}"
    end
    puts "Average load time %0.2fms" % [@ms.inject(0) { |memo, ms| memo+=ms; memo }/@ms.size]
    puts
    kill
  end
end