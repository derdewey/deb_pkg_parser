#!/usr/bin/env ruby
require 'zlib'
require 'find'
require 'pp'
require 'treetop'
require 'yajl'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, "syntax_nodes.rb")
require File.join(base_path, "package_list.rb")
Treetop.load(File.join(base_path,'debian.treetop'))
Treetop.load(File.join(base_path,'debian_apt_sources.treetop'))

source = File.read("/etc/apt/sources.list")
sources_parser = DebianAptSourcesParser.new
parsed = sources_parser.parse(source)
urls = parsed.elements.select{|x| x.kind_of?(DebianSyntaxNode::SourceListUrl)}.collect{|x| x.text_value.gsub!(" ","/").chomp!}
pp urls
exit(0)

# Xavier's little debian Packages.gz parser. Going off Clifford's advice, this will
# split the package list into package entries to parse and collect. It will not parse the entire file at once.
# Big picture, the packages I want to integrate into a stock debian
desired = %w{ git-core openssh-server libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev pkg-config libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 vim }

parser = DebianParser.new
parser.consume_all_input = false

local_package_list = PackageList.new

package_paths = Find.find("/home/xavierlange/code/defenderOS/dists").select{|x| x =~ /Packages\.gz/}
package_paths.each do |package_path|
  Zlib::GzipReader.open(package_path) do |unzipped|
    content = unzipped.read # File.read("sample_entry.txt")
    raw_list = content.split(/^\n/)
    raw_list.each do |raw_entry|
      parsed_entry = parser.parse(raw_entry)
      raise(RuntimeError, "===== Could not parse entry ====\n#{raw_entry}") if(parsed_entry.nil?)
      local_package_list << parsed_entry.values
    end
  end
end

result = []
not_found = []
desired.each do |des_pkg_name|
  if local_package_list.contains?(des_pkg_name)
    result << des_pkg_name
  else
    not_found << des_pkg_name
  end
end

pp "Not found locally: #{not_found.join(',')}"
pp "Found locally: #{result.join(',')}"



exit(0)
