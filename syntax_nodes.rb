module DebianSyntaxNode
  class Package < Treetop::Runtime::SyntaxNode
    attr_accessor :values
    def initialize(*args)
      super(*args)
      @values = {}
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
      puts @values
      @values
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
end
