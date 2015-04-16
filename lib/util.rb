module Util
  extend self
  
  def mps_to_kph(val)
    val * 3.6 rescue 0
  end

end
