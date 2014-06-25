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
end
