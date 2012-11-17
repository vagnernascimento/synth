require "rubygems"
module InterfaceRules
  
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
		
    #== To do: discover why do not work using a Hash as parameters
		#def evaluate_node(values_to_eval = nil)
		def evaluate_node(current_node_interactor, current_node_value, parent_node_iteractor = nil, parent_node_value = nil)
			interface_data = @interface_data
			engine = Wongi::Engine.create
      rules = @rules_array
			
			@facts.each{| fact | engine << fact }
      engine << ruleset{ 
				interface_data.each{ | k, v | 
					instance_variable_set( eval(":@#{k}"), v )
				}
	
				rules.each{ | str_rule |
					begin
						eval("#{parent_node_iteractor.to_s} = parent_node_value") unless (parent_node_iteractor.nil? or parent_node_value.nil?)
						eval("#{current_node_interactor.to_s} = current_node_value") unless (current_node_interactor.nil? or current_node_value.nil?)
						eval("maps_to #{str_rule}") 
					rescue Exception => e  
						#puts "Evaluation of Interface rules failed (repeatable node)"
						#puts e.message  
						#puts e.backtrace.inspect 
					end
				}
			}
      return selected_elements(engine)
    end
    
    def evaluate(facts, str_rules, interface_data = {})
			
			#== Instance values
			@facts = facts
			@str_rules = str_rules
			@rules_array =  str_rules.split('maps_to')
			rules = @rules_array
			@interface_data = interface_data
			
			#== New wongi engine
			@engine = Wongi::Engine.create
			@facts.each{| fact | @engine << fact }
			
      @engine << ruleset{ 
				interface_data.each{ | k, v | 
					instance_variable_set( eval(":@#{k}"), v )
				}
				rules.each{ | str_rule |
					begin
						eval("maps_to #{str_rule}") 
					rescue Exception => e 
						puts "Evaluation of Interface rules failed"
						puts e.message 
						puts e.backtrace.inspect 
					end
				}
			}
			#== main selected elements
      @selected = selected_elements(@engine)
      return compose(@hash) 
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
		
		#== PRIVATE METHODS
		private

		def selected_elements(engine)
			selected_elements = {}
			engine.each :_, "maps_to", :_ do | element |
				selected_elements[element[0]] ||= element[2]
			end
			return selected_elements
		end


		def compose(hash_tree)
			element_name = hash_tree[:name]
			
			if @selected[element_name].is_a?(Hash) #== Checks if node was previously selected by the first evaluation
				hash_tree[:node_content] = @selected[element_name]
				@direct_node_ref[element_name] = true
				if hash_tree[:children].is_a?(Array)
					#== Generates reapeatable nodes
          new_children = repeatable_children_nodes(hash_tree)
					unless new_children.nil? 
            hash_tree[:children] = new_children
						
					else
            hash_tree[:children].each_index do |index|
              selected = compose(hash_tree[:children][index])
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
		
		def get_cloned_node_name( name )
			@cloned_nodes_by_source[ name ] ||= { total: 0, clones: Array.new }
			@cloned_nodes_by_source[ name ][:total] = @cloned_nodes_by_source[ name ][:total] + 1 
			new_name = "#{name}_#{@cloned_nodes_by_source[ name ][:total]}"
			@cloned_nodes_by_source[ name ][:clones] << new_name
			return new_name
		end
		
		def populate_cloned_children(children, selected_nodes, parent_iterator_name, parent_instance_value)
      children.each_index do |index|
		 
				#-- Populates with values of selected node
				if selected_nodes[children[index][:name]].is_a?(Hash)
					source_node_name = children[index][:name]
					children[index][:node_content] = selected_nodes[children[index][:name]]
					#-- rename the new node
					source_node_name ||= rand(36**8).to_s(36)
					children[index][:name] = get_cloned_node_name(source_node_name)
					#-- Has children?
					unless children[index][:children].nil?
						new_children = repeatable_children_nodes(children[index], parent_iterator_name, parent_instance_value) #== For Nested collections
						unless new_children.nil?
							children[index][:children] = new_children
						else
							populate_cloned_children(children[index][:children], selected_nodes, parent_iterator_name, parent_instance_value) 
						end
					end
				else
					children[index] = nil
				end

      end
			return children.compact!
    end
    
    def repeatable_children_nodes(current_node, parent_iterator_name = nil, parent_instance_value = nil)
      
      if current_node[:repeatable] == true
        new_children = [] #== For children populated with collection
				collection = current_node[:node_content][:params][:collection]
				iterator_name = current_node[:node_content][:params][:as] || 'value'
				
        if collection.is_a?(Array)
					collection.each do | instance_value |
						
						selected_nodes = evaluate_node(iterator_name, instance_value, parent_iterator_name, parent_instance_value) #== The last iterator (parent) of collection is sent
						if selected_nodes.is_a?(Hash)
							children_clone = Marshal.load( Marshal.dump(current_node[:children]) ) #== Clonning nodes
							populate_cloned_children(children_clone, selected_nodes, iterator_name, instance_value)
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
				#hash[:name] = "#{hash[:extension]}_#{rand(36**8).to_s(36)}"
				#hash[:name] = hash[:extension]
				new_nodes = Array.new
				hash[:nodes].each{ | node |
					if @direct_node_ref[ node ] == true
						new_nodes << node
					else
						new_nodes = new_nodes + @cloned_nodes_by_source[ node ][:clones] if @cloned_nodes_by_source[ node ].is_a?(Hash)
					end
				}
				hash[:nodes] = new_nodes
				@extention_list << hash
			end
		end
		
  end
	
end