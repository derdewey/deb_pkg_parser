module ElementTraversalMixin
  def each_element(parent=self,&block)
    begin
      yield parent
    rescue => e
      puts %Q{sup #{e.backtrace.join("\n")}}
    end
    return if parent.terminal?
    parent.elements.each do |child|
      next if child.terminal?
      begin
      each_element(child) do |r|
        yield r
      end
      rescue
          puts 'aios mios'
      end
    end
  end
end

module DebianSyntaxNode
  class Package < Treetop::Runtime::SyntaxNode
    attr_accessor :values
    def initialize(*args)
      super(*args)
      @values = {}
      resolve
    end

    # Traverse the elements tree and start putting entries into the @values hash
    # TODO: Either fix the parser so that ValueLine is all the data at once or
    # come up with a less flakey way fo combining adjacent ValueLine's into their
    # TagValue entry.
    def resolve
      elements.inject(@values) do |container,ele|
        container.merge!(ele.elements[0].text_value.strip.gsub(":","") => ele.elements[1].text_value.strip)
        container
      end
      raise RuntimeError, "No package name found for\n#{text_value}" if @values["Package"].nil?
      @values
    end
    def name
      @values["Package"]
    end
  end

  class Tag < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
  end
  class Value < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
  end
  class PackageName < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
  end

  class Dependency < Value
  end
  class ComparativeDependency < Dependency
    include ElementTraversalMixin

    attr_accessor :package_name, :version, :comparator
    def initialize(*args)
      super(*args)
      # Super lazy way, just go through results and cherry pick results. N00b alert
      each_element do |ele|
        if(ele.class.eql?(DebianSyntaxNode::PackageName))
          @package_name = ele.text_value
        elsif(ele.class.eql?(DebianSyntaxNode::DependencyComparator))
          @comparator = ele.text_value
        elsif(ele.class.eql?(DebianSyntaxNode::DependencyVersion))
          @version = ele.text_value
        end
      end
    end
  end
  class SubstitutableDependency < Dependency
    include ElementTraversalMixin
    
    attr_accessor :possibilities
    def initialize(*args)
      super(*args)
      temp = []
      each_element do |ele|
        temp << ele if ele.kind_of?(DebianSyntaxNode::PackageName)
      end
      @possibilities = temp.collect{|x| x.text_value}
    end
  end
  class DependencyComparator < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
  end
  class DependencyVersion < Treetop::Runtime::SyntaxNode
  end
  class DependencyList < Treetop::Runtime::SyntaxNode
    include ElementTraversalMixin
    attr_accessor :list
    def initialize(*args)
      super(*args)
      @list = []
      each_element do |ele|
        if(ele.kind_of?(DebianSyntaxNode::Dependency))
          @list << ele
        end
      end
      pp @list
    end
  end
  class SourceList < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
  end
  class SourceListUrl < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
    end
    def resolve
      text_value.gsub!(" ","/").chomp!
    end
  end
end
