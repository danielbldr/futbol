module Calculable
  def average(array)
    (array.sum / array.length.to_f).round(2)
  end

  def percentage(part, total)
    (part.length.to_f/total.length).round(2)
  end
end
