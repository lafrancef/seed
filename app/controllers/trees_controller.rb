class TreesController < ApplicationController
	
	# Show the form for creating a new tree
	def new
	end
	
	# Actual creation of the tree
	def create
		@tree = Tree.new
		@tree.name = tree_params[:name]
		session[:import] = false
		
		if not (tree_params[:brackets].nil? or tree_params[:brackets].empty?)
			@tree.parse_txt(tree_params[:brackets])
			session[:import] = true
		end
		@tree.save
		redirect_to @tree
	end
	
	# Show the tree itself
	def show
		@tree = Tree.find(params[:id])
		@import = session[:import]
		session[:import] = nil
		respond_to do |format|
			format.html
			format.txt { render plain: @tree.export_txt }
		end
		# TODO Do something if we can't find the tree
	end
	
	# Update (save) the tree
	def update
		# TODO Validation around here
		params[:tree].each do |node_json|
			begin
				node_obj = Node.find_by!(tree_id: params[:id], relative_id: node_json['id'])				
			rescue
				node_obj = Node.new
				node_obj.tree_id = params[:id]
				node_obj.relative_id = node_json['id']
			end
			
			#TODO Change json names so that they reflect what's in the database
			node_obj.part_of_speech = node_json['pos']
			
			node_obj.x = node_json['x']
			node_obj.y = node_json['y']
			node_obj.pid = node_json['pid']
			
			node_obj.case_marker = node_json['case']
			node_obj.theta = node_json['theta']
			
			node_obj.type = node_json['type']
			if node_json['type'] == 'Node'
				node_obj.contents = node_json['content']
				node_obj.trace_id = node_json['trace_id']
			else
				node_obj.trace_idx = node_json['trace_idx']
			end
			
			node_obj.save
		end
		
		if not params[:del].nil?
			params[:del].each do |node|
				to_delete = Node.find_by(tree_id: params[:id], relative_id: node)
				if not to_delete.nil?
					to_delete.delete
				end
			end
		end
		
		
		render json: {status => 0}
	end
	
	private
		def tree_params
			params.require(:tree).permit(:name, :brackets)
		end
end
