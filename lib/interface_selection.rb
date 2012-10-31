
module InterfaceSelection

	def render_interface(facts_source)
		# Extract facts from { :nav_element => @context, :current_node=> @node, :user_agent => request.user_agent, :environment => request.env }
		
		selected_interface = select_interface(facts_source)
		#return selected_interface.inspect
		return selected_interface ? selected_interface.label : nil
	end
	
	private
	def select_interface(facts_source)
		for interface in SWUI::Interface.interfaces_by_weight do
			if interface.evaluate_selection_rule(facts_source)
				return interface 
			end
		end
		return nil
	end



end