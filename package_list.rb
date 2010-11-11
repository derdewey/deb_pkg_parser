class PackageList
  def initialize
    @list = []
  end
  def add(pkg)
    @list << pkg
  end
  def <<(pkg)
    @list << pkg
  end
  def contains?(pkg_name)
      !@list.select{|x| x["Package"] == pkg_name}.empty?
  end
end
