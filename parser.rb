#!/usr/bin/env ruby
require 'zlib'
require 'find'
require 'pp'
#require 'polyglot'
require 'treetop'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, "syntax_nodes.rb")
Treetop.load(File.join(base_path,'debian.treetop'))

#grammar = File.read(File.join(File.dirname(__FILE__), 'debian.treetop'))
#Treetop.load(grammar)
parser = DebianParser.new
parser.consume_all_input = false

# What I want to install
# git-core openssh-server libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev pkg-config libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 vim
tree = nil
Zlib::GzipReader.open("./Packages.test.gz") do |unzipped|
  content = unzipped.read
  tree = parser.parse(content)
  raise(RuntimeError, "Could not parse file!") if(tree.nil?)
end
pp tree

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
