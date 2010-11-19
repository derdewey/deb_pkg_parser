#!/usr/bin/env ruby
require 'zlib'
require 'pp'
require 'optparse'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, "syntax_nodes.rb")
require File.join(base_path, "package_list.rb")
require File.join(base_path, "source_list.rb")

#not_found_dependencies = %w{
#  git-core libpcre3-dbg libpcre3-dev autoconf automake libtool
#  libpcap-dev libnet1-dev libyaml-dev zlib1g-dev pkg-config
#  libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0
#  perlapi-5.10.1
#}
opts = {:action => nil,
        :search => nil,
        :destination => nil,
        :packages => %w{ git-core openssh-server libpcre3 libpcre3-dbg libpcre3-dev build-essential
                         autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev
                         zlib1g zlib1g-dev pkg-config libnetfilter-queue-dev libnetfilter-queue1
                         libnfnetlink-dev libnfnetlink0 vim }
}

optparser = OptionParser.new do |options|
  # Inference engine...
  options.on('-s','--search=[dir,sources,(local_repo,remote_repo)]','Root folder containing Packages.gz or a sources.list referencing repositories') do |src|
    opts[:search] = src
  end
  options.on('-d','--destination=','Either a) local filename for creating db, or a dir for installing .debs', "(e.g.: cd_packages.db or $NEW_DISTRO/dists)") do |dst|
    opts[:destination] = dst
  end
  options.on('-p foo1,bar1,...', '--packages=foo1,bar1,...','Packages to install. Dependencies will also be resolved.') do |deps|
    opts[:packages] = deps.split(',')
  end
end
optparser.parse(ARGV)

if(opts[:search].nil?)
  raise ArgumentError, ":search cannot be nil"
elsif(opts[:search] =~ /\.list$/)
  puts "Going for a source file!"
  SourceList.new(:source => opts[:search])
elsif(opts[:search].split(",").length == 2)
  puts "Dependency hunt"
  local,remote = opts[:search].split(",")
  local_pkg_list = PackageList.deserialize(:source => local)
  exit
  remote_pkg_list = PackageList.deserialize(:source => remote)
else
  puts "Must be a directory!"
  retval = PackageList.search(opts)
  pp retval
end
exit
%w{
  git-core libpcre3-dbg libpcre3-dev autoconf automake libtool
  libpcap-dev libnet1-dev libyaml-dev zlib1g-dev pkg-config
  libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0
  perlapi-5.10.1
}

addrs = %w{
http://vcamirror.viasat.com/ubuntu/pool/main/g/git-core/git-core_1.7.0.4-1_i386.deb
http://vcamirror.viasat.com/ubuntu/pool/main/a/autoconf/autoconf_2.67-2ubuntu1_all.deb
}

#result = []
#not_found = []
#puts "Round One"
#not_found_dependencies.each do |des_pkg_name|
#  if cd_package_list.contains?(des_pkg_name)
#    result << des_pkg_name
#  else
#    not_found << des_pkg_name
#  end
#end
#pp "Not found locally: #{not_found.join(',')}"
#pp "Found locally: #{result.join(',')}"
#
#exit(0)
