module Calculable
  def average(array)
    (array.sum / array.length.to_f).round(2)
  end
end
