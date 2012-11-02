require "interface-rules"

SWUI::Interface

module SWUI
	class SWUI::Interface
		
		# Interface properties
		property SWUI::interface_name, 'rdfs:subPropertyOf' => RDFS::label
		property SWUI::interface_selection_rule
		property SWUI::interface_weight
		property SWUI::interface_title
		property SWUI::abstract_scheme
		property SWUI::abstract_rules
		property SWUI::concrete_mapping_rules
		
		#== Class methods
		def self.interfaces_by_weight
			interfaces = SWUI::Interface.find_all
			interfaces.sort!{ | x, y | (x.interface_weight.to_s.to_i || 0) <=> (y.interface_weight.to_s.to_i || 0) }
		end
		
    def self.select_interface(facts_triples)
      for interface in SWUI::Interface.interfaces_by_weight do
        if interface.evaluate_selection_rule(facts_triples)
          return interface 
        end
      end
    end
		
    #== Instance methods
		def evaluate_selection_rule(facts_triples = [])
			
			unless self.interface_selection_rule.empty?
				instance_rule = InterfacerRules::SelectionRule.new( self.interface_selection_rule.to_s )
        #== Adding facts
				instance_rule.add_facts(facts_triples)
				return instance_rule.is_true?
			end
		end

    
		private
		
		
	end
end