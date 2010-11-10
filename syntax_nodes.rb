module DebianSyntaxNode
  class PackageList < Treetop::Runtime::SyntaxNode
    def initialize(*args)
      super(*args)
      puts "PackageList is ready to go!"
      resolve
    end
    def resolve
      pp "Hi"
    end
  end

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
      tracker = nil
      elements.inject(@values) do |container,ele|
        if ele.kind_of?(Tag)
          tracker = ele.elements.first.text_value
          container.merge!({tracker => ""})
        elsif ele.kind_of?(Value)
          ele.elements.each do |value|
            if value.kind_of?(ValueLine)
              container[tracker] += value.text_value
            end
          end
        else
          raise RuntimeError, "unknown class my code is goofy!"
        end
        container
      end
      @values
    end
  end

  class Tag < Treetop::Runtime::SyntaxNode
  end
  class TagValue < Treetop::Runtime::SyntaxNode
  end
  class TagStop < Treetop::Runtime::SyntaxNode
  end

  class Value < Treetop::Runtime::SyntaxNode
  end
  class ValueLine < Treetop::Runtime::SyntaxNode
  end
  class ValueStop < Treetop::Runtime::SyntaxNode
  end
end
