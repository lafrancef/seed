class Tree < ActiveRecord::Base
	has_many :nodes
	
	def root
		root = nodes.where('pid is null')
		if root.length != 1
			raise 'There should only be one root.'
		end
		
		return root[0]
	end
	
	def leaf? (node)
		return (not nodes.exists?(pid: node['relative_id']))
	end
	
	def children (node)
		return nodes.where(pid: node['relative_id']).order(:x)
	end
	
	def node_str (node)
		res = '[' + node['part_of_speech'] + ' '
		if self.leaf?(node)
			res += node['contents']
		else
			self.children(node).each do |child|
				res += self.node_str(child)
			end
		end
		
		return res + ']'
	end
	
	def export_txt
		return self.node_str(self.root)
	end
	
	def parse_node (src, pid, next_node_id)
		
		match_pos = src.match(/^\[\s*(\w+)\s*/)
		if match_pos.nil?
			raise "No part of speech"
		end

		node = Node.new
		node.relative_id = next_node_id
		node.pid = pid
		node.type = "Node"
		node.part_of_speech = match_pos[1]

		node.x = 0
		node.y = 0

		node.theta = false
		node.case_marker = false

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
						raise "Unmatched bracket"
					end
				end
			end

			return next_node_id

		else # This is normally a leaf
			# Obtain the contents
			match_contents = src[match_pos.end(0), src.length - match_pos.end(0)].match(/(.*)\]/)
			if match_contents.nil?
				raise "Unmatched bracket"
			end

			node.contents = match_contents[1]
			self.nodes << node

			return 1
		end

	end

	def parse_txt (src)
		src.rstrip!
		src.lstrip!

		match_data = src.match(/^\[(.)*\]$/)
		if not match_data.nil?
			self.parse_node(match_data[0], nil, 0)
		else
			raise "Parse error"
		end
	end
end
