require "#{RAILS_ROOT}/lib/interface_rules.rb"

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
		
		
		def self.interfaces_by_weight
			interfaces = SWUI::Interface.find_all
			interfaces.sort!{ | x, y | (x.interface_weight.to_s.to_i || 0) <=> (y.interface_weight.to_s.to_i || 0) }
		end
		
		# Extract facts from { :nav_element => @context, :current_node=> @node, :user_agent => request.user_agent["HTTP_USER_AGENT"], :environment => request.env }
		# To do ===> Add params!
		def evaluate_selection_rule(facts_triples = [])
			
			unless self.interface_selection_rule.empty?
				inst_rule = InterfaceRules::InstanceRule.new( self.interface_selection_rule.to_s )
				#== Adding facts
				inst_rule.add_facts(facts_triples)
				return inst_rule.is_true?
			end
		end
		
		private
		
		
	end
end