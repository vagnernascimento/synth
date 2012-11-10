module InterfaceRules
 
  #VERSION '0.1.1'
  require "rubygems"
	class Dummy  
		def method_missing(m, *args, &block)  
			
		end  
	end
  class InterfaceRules::ConcreteInterface
		 include ExtendDSLRules
    def initialize(hash)
			@hash = hash
		end
		
		def hash
			@hash
		end
		
    def evaluate_node(facts, str_rules, interface_data = {}, value)
			engine = Wongi::Engine.create
      facts.each{| fact | engine << fact }
      engine << ruleset{ 
				interface_data.each{ | k, v | 
					instance_variable_set( eval(":@#{k}"), v )
				}
				#begin
				eval(str_rules) 
				#rescue
				#end
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
				eval(str_rules) 
			}
      @selected = selected_elements(@engine)
      
      return compose(@hash, facts, str_rules, interface_data) 
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
					children[index][:node_content] = selected_nodes[children[index][:name]]

					#-- rename the new node
					children[index][:name] ||= rand(36**8).to_s(36)
					children[index][:name] = children[index][:name] + '_'+ counter_parent.to_s + '_' + counter.to_s
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
				values = current_node[:node_content][:params][:values]
        if values.is_a?(Array)
					values.each do | value |
						selected_nodes = evaluate_node(facts, str_rules, interface_data, value)
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
		
  end
	
end