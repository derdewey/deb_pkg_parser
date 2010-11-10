module DebianSyntaxNode
  class PackageList < Treetop::Runtime::SyntaxNode
  end

  class Package < Treetop::Runtime::SyntaxNode
    attr_accessor :values
    def initialize(*args)
      super(*args)
      @values = {}
      puts "#{elements[0].elements[0].text_value.inspect} AND #{elements[1].elements[0].text_value.inspect}"
      resolve
    end
    def resolve
      elements.inject([]) do |cont,ele|
        if ele.kind_of?(Tag)
          cont.push({:tag => ele.elements.first.text_value, :value => ""})
        elsif ele.kind_of?(Value)
          ele.elements.each do |value|
            if value.kind_of?(ValueLine)
              cont.last[:value] += value.text_value
            end
          end
          pp cont.last
        else
          raise RuntimeError, "unknown class!"
        end

        cont
      end
      exit(1)
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
