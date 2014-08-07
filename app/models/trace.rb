class Trace < Node
  def to_s
    return super.to_s + 
	        ", traceIdx: \"" + trace_idx.to_s + "\""
  end
end
