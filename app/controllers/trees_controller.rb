class TreesController < ApplicationController
	
	#List the user's trees
	def index
		if cookies[:seed_id].nil?
			cookies.permanent[:seed_id] = get_new_id
		else
			@trees = Tree.where(uid: cookies[:seed_id])
		end
	end
	
	# Show the form for creating a new tree
	def new
	end
	
	# Actual creation of the tree
	def create
		@tree = Tree.new
		@tree.name = tree_params[:name]
		@tree.uid = cookies[:seed_id]
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
				node_obj.show_content = node_json['show_content']
				node_obj.show_triangle = node_json['show_triangle']
			else
				node_obj.trace_idx = node_json['trace_idx']
				node_obj.show_content = false
				node_obj.show_triangle = false
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
		
		def get_new_id
			begin
				id_file = File.open (Rails.root + "userid/userid.txt"), "r"
				id = id_file.read.to_i
				id_file.close
			rescue
				id = 0
			end

			id_file = File.open (Rails.root + "userid/userid.txt"), "w"
			id_file.write (id + 1).to_s
			id_file.close
			
			return id
		end
end
