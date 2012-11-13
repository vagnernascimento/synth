require "rubygems"
module InterfaceRules
 
	class Dummy  #== Only for simulation of fake objects
		def method_missing(m, *args, &block)  
		end  
	end

  class InterfaceRules::ConcreteInterface
		 include ExtendDSLRules
    def initialize(hash)
			@hash = hash
			@cloned_nodes_by_source = Hash.new
			@extention_list = Array.new
			@direct_node_ref = Hash.new
		end
		
		def cloned
			@cloned_nodes_by_source
		end
		
		def hash
			@hash
		end
		
    def evaluate_node(facts, str_rules, interface_data = {}, value, interator_name)
			interator_name = interator_name.nil? ? 'value' : interator_name
			engine = Wongi::Engine.create
      facts.each{| fact | engine << fact }
      engine << ruleset{ 
				interface_data.each{ | k, v | 
					instance_variable_set( eval(":@#{k}"), v )
				}
				begin
					eval( "#{interator_name.to_s} = value")
					eval(str_rules) 
				rescue Exception => e  
					puts "Evaluation of Interface rules failed (repeatable node)"
					puts e.message  
					#puts e.backtrace.inspect 
				end
			}
      return selected_elements(engine)
    end
    
    def evaluate(facts, str_rules, interface_data = {})
			value = Dummy.new
			@engine = Wongi::Engine.create
			facts.each{| fact | @engine << fact }
			
      @engine << ruleset{ 
				interface_data.each{ | k, v | 
					instance_variable_set( eval(":@#{k}"), v )
				}
				begin
					eval(str_rules) 
				rescue Exception => e 
					puts "Evaluation of Interface rules failed"
					puts e.message  
				end
			}
      @selected = selected_elements(@engine)
      
      return compose(@hash, facts, str_rules, interface_data) 
		end	

		
		def evaluate_extensions(extension_str)
			if extension_str.is_a?(String)
				eval(extension_str)
				@extention_list
			end
		end
		
		def extensions_hash
			@extention_list
		end
		
		private

		def selected_elements(engine)
			selected_elements = {}
			engine.each :_, "maps_to", :_ do | element |
				selected_elements[element[0]] ||= element[2]
			end
			return selected_elements
		end


		def compose(hash_tree, facts, str_rules, interface_data)
			element_name = hash_tree[:name]
			
			if @selected[element_name].is_a?(Hash) #== Checks if node was previously selected by the first evaluation
				hash_tree[:node_content] = @selected[element_name]
				@direct_node_ref[element_name] = true
				if hash_tree[:children].is_a?(Array)
					#== Generates reapeatable nodes
          new_children = repeatable_children_nodes(hash_tree[:children], hash_tree, facts, str_rules, interface_data)
					unless new_children.nil? 
            hash_tree[:children] = new_children
						
					else
            hash_tree[:children].each_index do |index|
              selected = compose(hash_tree[:children][index], facts, str_rules, interface_data)
              hash_tree[:children][index] = nil unless selected #== if it was not selected by the rules, clear the node.
            end
            hash_tree[:children].compact! #== Remove blank nodes (unselected by rules)
          end
				end
			else
				return false
			end
			return hash_tree
		end

	def populate_cloned_children(children, selected_nodes, counter_parent, counter = 0)
      children.each_index do |index|
        #-- Populates with values of selected node
        if selected_nodes[children[index][:name]].is_a?(Hash)
					source_node_name = children[index][:name]
					children[index][:node_content] = selected_nodes[children[index][:name]]

					#-- rename the new node
					children[index][:name] ||= rand(36**8).to_s(36)
					children[index][:name] = children[index][:name] + '_'+ counter_parent.to_s + '_' + counter.to_s
					@cloned_nodes_by_source[ source_node_name ] ||= Array.new
					@cloned_nodes_by_source[ source_node_name ] << children[index][:name]
					populate_cloned_children(children[index][:children], selected_nodes, counter_parent, counter + 1) unless children[index][:children].nil?
				else
					children[index] = nil
				end
      end
			return children.compact!
    end
    
    def repeatable_children_nodes(children, current_node, facts, str_rules, interface_data)
      
      if current_node[:repeatable] == true
        c = 0
        new_children = []
				values = current_node[:node_content][:params][:collection]
				interator_name = current_node[:node_content][:params][:as]
        if values.is_a?(Array)
					values.each do | value |
						selected_nodes = evaluate_node(facts, str_rules, interface_data, value, interator_name)
						selected_nodes.each{ |k,v| 
            }
						if selected_nodes.is_a?(Hash)
							children_clone = Marshal.load( Marshal.dump(children) ) #== Clonning nodes
							populate_cloned_children(children_clone, selected_nodes, c+=1)
							new_children = new_children + children_clone
						end
					end
  				return new_children
				end
      end
      
    end
		
		#== Extension method
		#== extend nodes: ['name_field', 'age_field', 'age_field' ], :extension => 'HTMLLineBreak'
		#== {:name => 'ext2', :extension => 'HTMLLineBreak', :nodes => ['name_field', 'age_field', 'age_field' ]},
		def extend(hash)
			if hash.is_a?(Hash)
				hash[:name] = "#{hash[:extension]}_#{rand(36**8).to_s(36)}"
				new_nodes = Array.new
				hash[:nodes].each{ | node |
					if @direct_node_ref[ node ] == true
						new_nodes << node
					else
						new_nodes = new_nodes + @cloned_nodes_by_source[ node ] if @cloned_nodes_by_source[ node ].is_a?(Array)
					end
				}
				hash[:nodes] = new_nodes
				@extention_list << hash
			end
		end
		
  end
	
end