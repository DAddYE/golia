require 'open-uri'
require 'net/http'
require 'fileutils'
require 'benchmark'
require 'tmpdir'

class Golia
  def initialize(link, validate)
    @okate = validate
    @host = begin
      link = "http://#{link}" unless link =~ /^http(s?)/
      "http#{$1}://" + URI.parse(link).host
    end

    @pid  = "#{Dir.tmpdir}/golia-#{URI.parse(link).host}"
    @checked, @links, @ko, @ok, @long, @invalid, @sec = [], [], [], [], [], [], []

    if File.exist?(@pid)
      puts "<= Founded stale pid"
      Process.kill(9, File.read(@pid).to_i) rescue nil
    end

    trap("INT") { puts "<= Golia has ended his set (crowd applauds)"; kill }

    begin
      parse!(link)
    rescue
      puts "<= Invalid url #{link}"
      kill
    end
  end

  def parse!(url)
    begun_at = Time.now
    response = open(url)
    @sec << Time.now-begun_at
    case File.extname(url)
      when ""
        body   = response.read
        links  = body.scan(/href=["'](.+?)["']/m).flatten
        links += body.scan(/<script.+?src=["'](.+?)["']/m).flatten
        links.reject! do |link|
          link =~ /^\/$|^https?|^mailto|^javascript|#|"|'/ ||
          File.extname(link) !~ /\.css|\.js|^$/
        end
        links.map! { |link| link = "/"+link if link !~ /^\//; @host+link }
        @links.concat(links-@checked)
      when /xml/i # maybe a sitemap
        body   = response.read
        links  = body.scan(/<loc>(http:\/\/.+)<\/loc>/).flatten
        @links.concat(links-@checked)
    end
  end

  def validate!(url)
    return   "\e[33mIgnore   \e[0m" if !@okate || File.extname(url) != ""
    body = open("http://validator.lipsiasoft.com/check?uri="+url).read
    body =~ /<title>.+?(\[invalid\]|\[valid\])/mi
    if $1 =~ /invalid/i
      @invalid << url
      return "\e[31mNot Valid\e[0m"
    else
      return "\e[32mValid    \e[0m"
    end
  end

  def kill
    Process.kill(9, Process.pid)
    FileUtils.rm_rf(@pid)
  end

  def start!
    loop do
      break if @links.empty?
      @links.each do |link|
        begin
          @checked << link
          parse!(link)
          @ok << link
          @long  << link if @sec.last > 1
          puts "\e[32mOK\e[0m - #{validate!(link)} - (%0.2fsec) %s" % [@sec.last, link]
        rescue Exception => e
          @ko << link
          puts "\e[31mKO\e[0m %s - %s" % [link, e.message]
        ensure
          @links.delete(link)
        end
      end
    end
    puts
    puts "======== SUMMARY ========"
    puts "OK Links: %d" % @ok.size
    puts "KO Links: %d" % @ko.size
    @ko.each do |link|
      puts "  #{link}"
    end
    puts "Long requests: %d" % @long.size
    @long.each do |link|
      puts "  #{link}"
    end
    puts "Invalid W3C Links: %d" % @invalid.size
    @invalid.each do |link|
      puts "  http://validator.lipsiasoft.com/check?uri=#{link}"
    end
    puts "Average load time %0.2fsec" % [@sec.inject(0) { |memo, sec| memo+=sec; memo }/@sec.size]
    puts
  end
end