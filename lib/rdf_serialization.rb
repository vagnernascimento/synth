module RdfSerialization
  
  def serialize
    case self.class.to_s
      when 'IndexEntryDecorator'
        self.IndexEntryDecorator_serializer
      when 'SHDM::ContextIndex::ContextIndexInstance'
        self.ContextIndexInstance_serializer
      when 'SHDM::Context::ContextInstance'
        self.ContextInstance_serializer
      when 'NodeDecorator'
        self.NodeDecorator_serializer
      else
        {}
    end
      
  end
  
  def parameters_to_url()
    if self.respond_to?(:parameters)
      parameters = self.parameters
      if parameters.is_a?(Hash) && !parameters.empty?
        parameters.merge!(parameters){|i,v| v.respond_to?(:uri) ? { "resource" => v.uri } : v }
        "?#{parameters.to_query}" 
      end
    end
  end
  
  protected
    ##############################
    #### Json format example #####
    ##############################
    
    # {"http://myIndexEntryResourceUrl" : {  "name" : [{"value" :"Paul Octopus", "url" : "http://context?node=http://paul }] }
    # -|------------------------------|----|--------|--|------------------------------------------------------------------|
    #         - Resource URI               - property            - hash with value and more details of the property
    
    def get_hash_node(node)
      if node.is_a?(IndexNodeAttribute)
       { :value => "#{CGI::escape(node.index.to_s)}#{node.parameters_to_url}", :type => node.class.to_s, :url => node.respond_to?(:target_url) ? node.target_url : nil, :parameters => node.parameters_to_url }
      else
        { :value => node.label.to_s, :type => node.class.to_s, :url => node.respond_to?(:target_url) ? node.target_url : nil }
      end
    end
    
    def IndexEntryDecorator_serializer
      uri = self.uri.to_s
      attributes_hash = self.attributes_hash
      hash_result = { uri => {} }
      self.attributes_names.each{|node| hash_result[uri][node] = [get_hash_node(attributes_hash[node])] }
      hash_result
    end
  
    def ContextIndexInstance_serializer
      { self.uri.to_s => {"shdm:index_title" => self.index_title, "shdm:index_nodes" => self.nodes.map{ |node| {:value => "#{node.to_s}#{node.parameters_to_url}"} }} }
    end
    
    def ContextInstance_serializer
      { self.uri.to_s => {"shdm:context_name" => self.context_name.to_s, "shdm:context_title" => self.context_title.to_s, "shdm:context_nodes" => self.resources.map{ |node| {:value => "#{node.to_s}#{node.parameters_to_url}"} }} }
    end
    
    def NodeDecorator_serializer
      uri = self.uri.to_s
      hash_result = { uri => {} }
      self.direct_properties.each{|property| hash_result[uri][property.label.to_a.empty? ? property.compact_uri : property.label.first] = [property.to_s] }
      hash_result
    end
end