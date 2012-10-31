require "useragent"
require "pp"

module InterfaceSelection

	def render_interface(facts_source)
		facts = Rules::Facts.new
		facts.convert_to_triples(facts_source)
		
		selected_interface = select_interface(facts.triples)
		
		return selected_interface ? selected_interface.label : nil
	end
	
	private

	def select_interface(facts_triples)
		for interface in SWUI::Interface.interfaces_by_weight do
			if interface.evaluate_selection_rule(facts_triples)
				return interface 
			end
		end
	end
	
	
end

module Rules
	class Facts
		
		def initialize(facts=[])
			@facts = facts 
		end
		
		def triples
			@facts
		end
		
		def <<(facts=[])
			@facts << facts 
		end
		
		def convert_to_triples(hash)
			if hash.is_a?(Hash)
				hash.each { |key, value|
					case value
						when Hash
							facts_from_hash(key.to_s, value)
						when RDFS::Resource, SHDM::Context::ContextInstance, SHDM::ContextIndex::ContextIndexInstance
							facts_from_properties(value)
						when String
							if key == :user_agent
								facts_from_user_agent(key.to_s, value)
							else
								self << [key.to_s, "literal", value]
							end
					end
				}
			end
		end
		
		private 
		
		def facts_from_user_agent(subject, str)
			unless str.empty?
				ua = UserAgent.parse(str)
				self << [subject, "browser", ua.browser]
				self << [subject, "browser_version", ua.version]
				self << [subject, "platform", ua.platform]
				self << [subject, "mobile", ua.mobile?]
			end
		end

		def facts_from_hash(subject, hash)
			hash.each {|key, value| self << [ subject, key, value ] } 
		end
		
		def facts_from_properties(node)
			unless node.nil?
				node.classes.each { | prop | 
					self << [ node.uri.to_s, "class", prop.to_s ] 
					self << [ node.uri.to_s, "rdf:type", prop.to_s ] 
				}
				node.direct_properties.each{ | prop | 
					predicate = prop.label.first.to_s || prop.first.to_s
					if prop.is_a?(Array)
						prop.each{ | value | self << [ node.uri.to_s, predicate, value.to_s ] }
					else
						self << [ node.uri.to_s, predicate, prop.to_s ] 
					end
				}
			end
			
		end

	end
end

