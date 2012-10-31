require "wongi-engine"

module InterfaceRules

	class InterfaceRules::InstanceRule
		include ExtendDSLRules

		def initialize(str_rule)
					
			@engine = Wongi::Engine.create
			if str_rule.is_a?(String)
				#begin			
					@rules = ruleset{ eval(str_rule) }
					#rules = ruleset{ set{ eq @index.label.first.to_s, "All Persons" } }
					@engine << @rules
				#rescue LoadError => e
				#	warn "The rule description is invalid"
				#end
				
			end
			
		end
		
		
		def engine
			@engine
		end
		def add_facts(facts)
			facts.each{| fact | @engine << fact }
		end
		
		def << (fact)
			@engine << fact
		end
		
		def is_true?()
			@engine.each :_, :_, :_ do | element |
				puts element
			end
			
			@engine.each :_, "selected", true do | element |
				return true
			end
			return false
		end
		
		
	end
end
