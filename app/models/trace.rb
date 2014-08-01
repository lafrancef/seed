class Trace < Node
  def to_s
    return super.to_s + 
	        ", trace_idx: " + trace_idx.to_s
  end
end
