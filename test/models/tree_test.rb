require "test_helper"
require "seed_exceptions"

class TreeTest < ActiveSupport::TestCase
	def choose_from (objs, attributes, values)
	# Choose an object among a list that must have
	# certain attribute values. If no object satisfies
	# the criteria, raise an exception
		if attributes.class != [].class
			attributes = [attributes]
		end
		
		if values.class != [].class
			values = [values]
		end
		
		attr_vals = attributes.zip values
		objs.each do |obj|
			satisfies = true
			attr_vals.each do | attr_val |
				if obj.send(attr_val[0]) != attr_val[1]
					satisfies = false
					break
				end
			end
			
			if satisfies
				return obj
			end
		end
		
		raise "No object matching attribute/values " + attr_vals.to_s
	end
	
	test "Leaf method" do
		carrier = trees(:carrier_1)
		child = choose_from(carrier.nodes, "part_of_speech", "child")
		parent = choose_from(carrier.nodes, "part_of_speech", "parent")
		
		assert(carrier.leaf? child)
		assert_not(carrier.leaf? parent)		
	end
	
	test "Root method on trees with one root" do
		carrier = trees(:carrier_1)
		child = choose_from(carrier.nodes, "part_of_speech", "child")
		parent = choose_from(carrier.nodes, "part_of_speech", "parent")
		
		assert_not_equal(carrier.root, child)
		assert_equal(carrier.root, parent)
	end
	
	test "Root method on trees with no/multiple roots" do
		nothing = Tree.new
		assert_nil(nothing.root)
		
		multiroot = trees(:multi_root_2)
		assert_raises Seed::TreeError do
			multiroot.root
		end
	end
	
	test "Children method" do
		carrier = trees(:carrier_1)
		child = choose_from(carrier.nodes, "part_of_speech", "child")
		parent = choose_from(carrier.nodes, "part_of_speech", "parent")
		
		assert_equal((carrier.children parent).length, 1)
		assert_equal((carrier.children parent)[0], child)

		assert_equal((carrier.children child).length, 0)		
	end
	
	test "Parsing: empty string" do
		empty = Tree.new
		empty.parse_txt ""
		
		assert_equal(empty.nodes.length, 0)
	end
	
	test "Parsing: empty brackets" do
		almost_empty = Tree.new
		almost_empty.parse_txt "[]"
		
		assert_equal(almost_empty.nodes.length, 1)
	end
	
	test "Parsing: normal case" do 
		# Create this tree
		#     E (Node 3)
		#	 /
		#	A   C (Node 1)
		#	 \ /
		#	  B
		#	   \
		#		D (Node 2)
		normal = Tree.new
		normal.parse_txt "[A [B [C Node 1] [D Node 2]] [E Node 3]]"
		normal.save
		
		assert_equal(normal.nodes.length, 5)
		assert_equal(normal.root, normal.nodes[0])
		
		eb = normal.children normal.root
		assert_equal(eb.length, 2)
		b = choose_from(eb, "part_of_speech", "B")
		e = choose_from(eb, "part_of_speech", "E")
		
		assert(normal.leaf? e)
		assert_equal(e.contents, "Node 3")
		
		cd = normal.children b
		assert_equal(cd.length, 2)
		c = choose_from(cd, "part_of_speech", "C")
		d = choose_from(cd, "part_of_speech", "D")
		
		assert(normal.leaf? c)
		assert(normal.leaf? d)
		assert_equal(c.contents, "Node 1")
		assert_equal(d.contents, "Node 2")
	end
	
	test "Parsing: unbalanced brackets 1" do
		unbalanced = Tree.new
		assert_raises Seed::TreeParseError do
			unbalanced.parse_txt "[A [B Content]]]"
		end
	end
	
	test "Parsing: unbalanced brackets 2" do
		unbalanced = Tree.new
		assert_raises Seed::TreeParseError do
			unbalanced.parse_txt "[A [B Content]"
		end
	end
	
	test "Parsing: text past the end" do
		test = Tree.new
		assert_raises Seed::TreeParseError do
			test.parse_txt "[A Foo] Bar"
		end
	end
	
	test "Parsing: nodes past the end" do
		test = Tree.new
		assert_raises Seed::TreeParseError do
			test.parse_txt "[F Foo] [B Bar]"
		end
	end
	
	test "Export: empty tree" do
		test = Tree.new
		assert_equal(test.export_txt, "")
	end
	
end
