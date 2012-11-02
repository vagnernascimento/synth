require "wongi-engine"
module ExtendDSLRules
  include Wongi::Engine
	
	#=== Defining new Wong methods
	module Wongi::Engine
		class Network
			def productions
				 @productions
			end
		end
		
		class Ruleset
			def set(rule_name = "rule", &block)
				rule rule_name do
					forall &block
					make{
						gen rule_name, "selected", true
					}
				end
			end
		end
	end
	
  
	
	#=== New DSL terms
	class GreaterThanTest < FilterTest
	
		attr_reader :x, :y

		def initialize x, y
			@x, @y = x, y
		end

		def passes? token
			x = if Wongi::Engine::Template.variable? @x
				token[@x]
			else
				@x
			end
			y = if Wongi::Engine::Template.variable? @y
				token[@y]
			else
				@y
			end
			return x > y
		end

	end

	class LessThanTest < FilterTest
		attr_reader :x, :y
		def initialize x, y
			@x, @y = x, y
		end

		def passes? token
			x = if Wongi::Engine::Template.variable? @x
				token[@x]
			else
				@x
			end
			y = if Wongi::Engine::Template.variable? @y
				token[@y]
			else
				@y
			end
			return x < y
		end

	end


	class GreaterThanEqualTest < FilterTest

			attr_reader :x, :y

			def initialize x, y
				@x, @y = x, y
			end

			def passes? token
				x = if Wongi::Engine::Template.variable? @x
					token[@x]
				else
					@x
				end
				y = if Wongi::Engine::Template.variable? @y
					token[@y]
				else
					@y
				end
				return x >= y
			end

		end

	class LessThanEqualTest < FilterTest
		attr_reader :x, :y
		def initialize x, y
			@x, @y = x, y
		end

		def passes? token
			
			x = if Wongi::Engine::Template.variable? @x
				token[@x]
			else
				@x
			end
			y = if Wongi::Engine::Template.variable? @y
				token[@y]
			else
				@y
			end
			return x <= y
		end

	end
	
	class LikeTest < FilterTest
		attr_reader :x, :y
		def initialize x, y
			@x, @y = x, y
		end

		def passes? token
			
			x = if Wongi::Engine::Template.variable? @x
				token[@x]
			else
				@x
			end
			y = if Wongi::Engine::Template.variable? @y
				token[@y]
			else
				@y
			end
			if x.is_a?(String) and y.is_a?(String)
				return !x.downcase.match(y.downcase).nil?
			else
				return false
			end
		end

	end
	
	
	dsl {
			section :forall
			
			clause :greaterThan, :gt
			accept GreaterThanTest
			
			clause :lessThan, :lt
			accept LessThanTest
			
			clause :greaterThanEqual, :gte
			accept GreaterThanEqualTest
			
			clause :lessThanEqual, :lte
			accept LessThanEqualTest
			
			clause :like, :as
			accept LikeTest
	}
end