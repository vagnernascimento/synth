require "interface-rules"

module InterfaceSelection

	def render_interface(facts_source, interface_data)
		facts = InterfaceRules::Facts.new
		facts.convert_to_triples(facts_source)
		
		#selected_interface = SWUI::Interface.select_interface(facts.triples)
		str_interface = SWUI::Interface.render(facts.triples, interface_data)
    return str_interface
		#return selected_interface ? selected_interface.label : nil
	end
	
end
