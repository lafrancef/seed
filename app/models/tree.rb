require "seed_exceptions"

class Tree < ActiveRecord::Base
	has_many :nodes
	
	def root
		root = nodes.where(pid: nil)
		if root.length > 1
			raise Seed::TreeError, "There should be exactly one root, not #{root.length}."
		elsif root.length == 0
			return nil
		end
		
		return root[0]
	end
	
	def leaf? (node)
		return (not nodes.exists?(pid: node.relative_id))
	end
	
	def children (node)
		return nodes.where(pid: node.relative_id).order(:x)
	end
	
	def node_str (node)
		if node.nil?
			return ''
		end
	
		res = '[' + node.part_of_speech
		if self.leaf?(node)
			# Normal node; add contents and potential trace identifier
			if node.type == 'Node' and not (node.contents.nil? or node.contents.empty?)
				res += ' ' + node.contents
				trace = nodes.find_by(relative_id: node.trace_id)
				if not trace.nil?
					res += '_' + trace.trace_idx
				end
			else # Trace; add trace identifier
				res += ' t_' + node.trace_idx
			end
		else
			children = self.children(node)
			if not children.empty?
				res += ' '
			end
			children.each do |child|
				res += self.node_str(child)
			end
		end
		
		return res + ']'
	end
	
	def export_txt
		return self.node_str(self.root)
	end
	
	def parse_node (src, pid, next_node_id)
		
		match_pos = src.match(/^\[\s*(\w*)\s*/)
		node = Node.new
		node.relative_id = next_node_id
		node.pid = pid
		node.type = 'Node'
		node.part_of_speech = match_pos[1]

		node.x = 0
		node.y = 0

		node.theta = false
		node.case_marker = false
		
		node.show_content = false
		node.show_triangle = false

		if src[match_pos.end(0)] == '['
			self.nodes << node

			start = match_pos.end(0)
			new_subtree = true
			for i in (start..src.length - 2) #Ignore the last closing bracket
				if src[i] == '['
					if new_subtree
						start = i 
						balance = 1
						new_subtree = false
					else
						balance += 1
					end
				elsif src[i] == ']'
					balance -= 1
					if balance == 0
						# Process this sub-tree
						next_node_id += self.parse_node(src.slice((start..i)), node.relative_id, next_node_id + 1)
						new_subtree = true
					elsif balance < 0
						raise Seed::TreeParseError, "Unmatched bracket"
					end
				end
			end
			
			if balance > 0
				raise Seed::TreeParseError, "Unmatched bracket"
			end
			return next_node_id

		else # This is normally a leaf
			# Obtain the contents
			match_contents = src[match_pos.end(0), src.length - match_pos.end(0)].match(/(.*)\]/)
			if match_contents.nil?
				raise Seed::TreeParseError, "Unmatched bracket"
			end
			
			if match_contents[1].include? "[" or match_contents[1].include? "]"
				raise Seed::TreeParseError
			end
			
			node.contents = match_contents[1]
			node.show_content = true
			self.nodes << node

			return 1
		end

	end

	def parse_txt (src)
		src.rstrip!
		src.lstrip!
		
		# Parsing nothing is a no-op
		if src.empty?
			return
		end
		
		match_data = src.match(/^\[(.)*\]$/)
		if not match_data.nil?
			self.parse_node(match_data[0], nil, 0)
		else
			raise Seed::TreeParseError, "Parse error"
		end
	end
end
