#!/usr/bin/env ruby
require 'zlib'
require 'find'
require 'pp'
require 'treetop'
require 'yajl'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, "syntax_nodes.rb")
Treetop.load(File.join(base_path,'debian.treetop'))

# Xavier's little debian Packages.gz parser. Going off Clifford's advice, this will
# split the package list into package entries to parse and collect. It will not parse the entire file at once.
# Big picture, the packages I want to integrate into a stock debian
# git-core openssh-server libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev pkg-config libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 vim



parser = DebianParser.new
parser.consume_all_input = false

package_list = []
Zlib::GzipReader.open("Packages.test.gz") do |unzipped|
    content = unzipped.read # File.read("sample_entry.txt")
    raw_list = content.split(/^\n/)
    raw_list.each do |raw_entry|
      # puts "Parsing entry's size: #{raw_entry.length}"
      parsed_entry = parser.parse(raw_entry)
      #package_list <<
      raise(RuntimeError, "===== Could not parse entry ====\n#{raw_entry}") if(parsed_entry.nil?)
    end
end
pp package_list
exit(1)

package_paths = Find.find("/home/xavierlange/code/defenderOS/dists").select{|x| x =~ /Packages\.gz/}
package_paths.each do |package_path|
  puts "Processing #{package_path}"
  Zlib::GzipReader.open(package_path) do |unzipped|
    content = unzipped.read
    raw_list = content.split(/^\n/)
    raw_list.each do |raw_entry|
      # puts "Parsing entry's size: #{raw_entry.length}"
      parsed_entry = parser.parse(raw_entry)
      #parsed_entry.resolve
      # exit(1)
      package_list << parsed_entry.resolve
      raise(RuntimeError, "Could not parse entry #{raw_entry}") if(parsed_entry.nil?)
    end
  end
end

pp package_list.sort{|x| x.keys.length}.first
package_list.collect{|x| "Length: #{x.keys.length}"}

encoder = Yajl::Encoder.new
File.open("package_list.json",'w') do |f|
  encoder.encode(package_list,f)
end

#sample = File.read("sample_entry.txt")

# pp tree
#tree.elements.each do |ele|
# pp ele.methods.sort
#end


#package_paths = Find.find('./dists').select{|x| x =~ /Packages\.gz/}
#package_paths.each do |path|
#  Zlib::GzipReader.open("dists/maverick/main/binary-i386/Packages.gz") do |unzipped|
#    content = unzipped.read
#    entry = content.split(/^\n/).first
#    puts entry
#    res = entry.scan(/^(.*):(.*)/m)
#    puts res.first.inspect
#    puts "*"*10
#    exit(0)
#  end
#end
