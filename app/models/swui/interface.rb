
require "#{RAILS_ROOT}/lib/interface_rules.rb"
require "useragent"
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
		
		# Extract facts from { :nav_element => @context, :current_node=> @node, :user_agent => request.user_agent, :environment => request.env }
		def evaluate_selection_rule(facts_source = {})
			
			unless self.interface_selection_rule.empty?
				inst_rule = InterfaceRules::InstanceRule.new( self.interface_selection_rule.to_s )
				#== Adding facts
				inst_rule.add_facts(facts_from_properties( facts_source[:nav_element])) #navigational_element
				inst_rule.add_facts(facts_from_properties( facts_source[:current_node])) #current_node
				inst_rule.add_facts(facts_from_user_agent( facts_source[:user_agent])) # User agent data
				inst_rule.add_facts(facts_from_hash( facts_source[:environment])) #environment data
				return inst_rule.is_true?
			end
		end
		
		private
		
		def facts_from_user_agent(str)
			facts = Array.new
			unless str.empty?
				ua = UserAgent.parse(str)
				facts << ["user_agent", "browser", ua.browser]
				facts << ["user_agent", "browser_version", ua.version]
				facts << ["user_agent", "platform", ua.platform]
				facts << ["user_agent", "mobile", ua.mobile?]
			end
			return facts
			
		end

		def facts_from_hash(hash)
			facts = Array.new
			hash.each {|key, value| 
			facts << [ "environment", key, value ] } 
			return facts
		end
		
		def facts_from_properties(node)
			facts = Array.new
			unless node.nil?
				node.classes.each { | prop | 
					facts << [ node.uri.to_s, "class", prop.to_s ] 
				}
				node.direct_properties.each{ | prop | 
					predicate = prop.label.first.to_s || prop.first.to_s
					if prop.is_a?(Array)
						prop.each{ | value |facts << [ node.uri.to_s, predicate, value.to_s ] }
					else
						facts << [ node.uri.to_s, predicate, prop.to_s ] 
					end
				}
			end
			return facts
		end
		
	end
end