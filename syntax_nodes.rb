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
