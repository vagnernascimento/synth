require "interface-rules"

module InterfaceSelection
	
	def render_interface(facts_source, interface_data)
		facts = InterfaceRules::Facts.new
		facts.convert_to_triples(facts_source)
		
		render_to_string :inline => SWUI::Interface.make_interface(facts.triples, interface_data).encode('UTF-8')
		#render :text => SWUI::Interface.make_interface(facts.triples, interface_data).encode('UTF-8')
    
	end
	
end
