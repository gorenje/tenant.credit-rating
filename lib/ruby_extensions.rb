class NilClass
  def empty?
    true
  end
end

class Array
  def average
    inject(&:+) / count.to_f
  end
end
