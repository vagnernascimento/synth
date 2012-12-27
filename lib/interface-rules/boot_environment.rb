require "rack/rewrite"
module InterfaceRewrite
		
		def self.rewrite
			Rails::Initializer.run do |config|
				config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
					#== TO DO: Improve it!!!
					
					#== REWRITE FOR SHARED FOLDER (JS, CSS, ETC)
					#== For image content-type
					send_file %r{/_shared/(.+\.)(?:ico|jpg|jpeg|png|gif)$}, Proc.new {|path, rack_env| InterfaceRewrite::file_path(path[0])}, 
					:headers => lambda { { 'Content-Type' => 'application/force-download' } }, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(_shared\/.+)$/)
						File.exists?( InterfaceRewrite::file_path(file[0]) ) if file
					}
					#== Other cases
					send_file %r{/_shared/(.+)}, Proc.new {|path, rack_env| InterfaceRewrite::file_path(path[0])}, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(_shared\/.+)$/)
						File.exists?( InterfaceRewrite::file_path(file[0]) ) if file
					}
					
					#== REWRITE FOR WIDGETS
					#== For image content-type
					send_file %r{/(concrete-widget/.+\.)(?:ico|jpg|jpeg|png|gif)$}, Proc.new {|path, rack_env| File.join(RAILS_ROOT, 'lib', 'interface-rules', path[0])},
					:headers => lambda { { 'Content-Type' => 'application/force-download' } }, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(concrete-widget\/.+)$/)
						File.exists?( File.join(RAILS_ROOT, 'lib', 'interface-rules',  file[0]) ) if file
					}
					#== Other cases
					send_file %r{/(concrete-widget/.+)}, Proc.new {|path, rack_env| File.join(RAILS_ROOT, 'lib', 'interface-rules', path[0])}, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(concrete-widget\/.+)$/)
						File.exists?( File.join(RAILS_ROOT, 'lib', 'interface-rules',  file[0]) ) if file
					}
			
					#== Rewrite for extensions
					#== For image content-type					
					send_file %r{/(extensions/.+\.)(?:ico|jpg|jpeg|png|gif)$}, Proc.new {|path, rack_env| File.join(RAILS_ROOT, 'lib', 'interface-rules', path[0])}, 
					:headers => lambda { { 'Content-Type' => 'application/force-download' } }, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(extensions\/.+)$/)
						File.exists?( File.join(RAILS_ROOT, 'lib', 'interface-rules',  file[0]) ) if file
					}
					#== Other cases
					send_file %r{/(extensions/.+)}, Proc.new {|path, rack_env| File.join(RAILS_ROOT, 'lib', 'interface-rules', path[0])}, 
					:if => Proc.new { |rack_env|
						file = rack_env['PATH_INFO'].match(/(extensions\/.+)$/)
						File.exists?( File.join(RAILS_ROOT, 'lib', 'interface-rules',  file[0]) ) if file
					}
				end
			end
			
		end
		
		def self.file_path(extra_path)
			File.join(RAILS_ROOT, 'lib', 'interface-rules',  extra_path)
		end
		
		def self.folder_list(folder_name)
			folder_path = InterfaceRewrite::file_path(folder_name)
			folders = Array.new
			Dir.entries(folder_path).select { |file| 
				if File.directory?(File.join(folder_path, file))
					folders << file
				end
			}
			return folders
		end
end