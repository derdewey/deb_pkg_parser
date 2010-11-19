base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, "syntax_nodes.rb")
Treetop.load(File.join(base_path,'debian.treetop'))
require 'yajl'
require 'find'

class PackageList
  attr_accessor :list, :parser, :source
  def initialize(opts = {})
    @parser = DebianParser.new
    @parser.consume_all_input = false
    @list = []
    @source = nil
  end
  def add(raw_entry,src=nil)
    package = @parser.parse(raw_entry)
    raise RuntimeError, "Could not parse\n========\n#{raw_entry}" if package.nil?
    @list << package
  end
  def lookup(pkg_name)
    @list.select{|x| x.name == pkg_name}
  end
  def contains?(pkg_name)
    !lookup(pkg_name).empty?
  end
  def dependencies(pkg_name)
    @list.select{|x| x.name =~ pkg_name}.collect{|x| x.dependencies}
  end
  def serialize(opts = {:destination => 'default.db'})
    pp "Serialize with opts #{opts}"
    dump = @list.collect{|x| x.values}
    File.open(opts[:destination],'w') do |f|
      f.write Marshal.dump(dump)
    end
  end
  def self.deserialize(opts= {:source => nil})
    retval = PackageList.new
    retval.list = Marshal.load(File.read(opts[:source]))
    return retval
  end
  def self.search(opts = {:search => nil})
    if(opts[:search].nil?)
      raise ArgumentError, "must provide :search"
    end
    package_paths = Find.find(opts[:search]).select{|x| x =~ /Packages\.gz/}
    package_list = PackageList.new
    package_paths.each{|x| from_gzip(x,package_list)}
    return package_list
  end
  def self.from_gzip(path, package_list)
    Zlib::GzipReader.open(path) do |unzipped|
      content = unzipped.read # File.read("sample_entry.txt")
      raw_list = content.split(/^\n/)
      length = raw_list.length
      puts "Number of possible entries: #{length}"
      count = 0
      raw_list.each do |raw_entry|
        package_list.add(raw_entry)
        puts Time.now if count % 100 == 0
        count += 1
      end
    end
  end
end
