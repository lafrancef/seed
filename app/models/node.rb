class Node < ActiveRecord::Base
  belongs_to :tree
  
  def to_s
    return "id: " + self.relative_id.to_s +
			", x: " + self.x.to_s +
			", y: " + self.y.to_s +
			", pos: \"" + self.part_of_speech.to_s +
			"\", contents: \"" + self.contents.to_s +
			"\", theta: " + self.theta.to_s +
			", caseMarker: " + self.case_marker.to_s
  end
end
