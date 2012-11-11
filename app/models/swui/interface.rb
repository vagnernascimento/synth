require "interface-rules"
require "pp"

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
		property SWUI::concrete_extensions
		
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
		
    def self.render(facts_triples = [], interface_data = {})
      selected_interface = self.select_interface(facts_triples)
      unless selected_interface.nil?
        abstract_scheme = eval(selected_interface.abstract_scheme.to_s)
        if abstract_scheme.is_a?(Hash)
          abstract_rules_str = selected_interface.abstract_rules.to_s
          
          #== Instances and evaluates the selected abstract interface
          abstract_interface_rules =  InterfaceRules::AbstractInterface.new( abstract_scheme )
          abstract_composed_hash = abstract_interface_rules.evaluate( facts_triples, abstract_rules_str )
         
					#== Concrete mapping
					concrete_mapping_rules_str = selected_interface.concrete_mapping_rules.to_s
					 
					unless concrete_mapping_rules_str.empty?
						
						concrete_interface_rules =  InterfaceRules::ConcreteInterface.new( abstract_composed_hash )
						concrete_composed_hash = concrete_interface_rules.evaluate( facts_triples, concrete_mapping_rules_str, interface_data )
						hash_extensions = concrete_interface_rules.evaluate_extensions( selected_interface.concrete_extensions.to_s )
						
            #return concrete_composed_hash
            #== Concrete rendering
						if  concrete_composed_hash.is_a?(Hash)
							#return concrete_composed_hash.to_s
							concrete_interface = ConcreteWidget::Interface.new(concrete_composed_hash)
							concrete_interface.add_extensions(hash_extensions)
							
							return concrete_interface.render
						else
							return "No interface could be composed"
						end
					end
          
        end
      end
    end
    
    #== Instance methods
		def evaluate_selection_rule(facts_triples = [])
			
			unless self.interface_selection_rule.empty?
				instance_rule = InterfaceRules::SelectionRule.new( self.interface_selection_rule.to_s )
        #== Adding facts
				instance_rule.add_facts(facts_triples)
				return instance_rule.is_true?
			end
		end

    
		private
		
		
	end
end