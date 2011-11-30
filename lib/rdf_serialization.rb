module RdfSerialization
  
  def rdf_to_serialized
    case self.class.to_s
      when 'IndexEntryDecorator'
        self.IndexEntryDecorator_to_serialized
      when 'SHDM::ContextIndex::ContextIndexInstance'
        self.ContextIndexInstance_to_serialized
      else
        {}
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
       { :value => node.index.to_s, :type => node.class.to_s, :url => node.respond_to?(:target_url) ? node.target_url : nil, :parameters => node.respond_to?(:parameters) ? node.parameters : nil  }
      else
        { :value => node.label.to_s, :type => node.class.to_s, :url => node.respond_to?(:target_url) ? node.target_url : nil }
      end
    end
    
    def IndexEntryDecorator_to_serialized
      uri = self.uri.to_s
      attributes_hash = self.attributes_hash
      hash_result = { uri => {} }
      self.attributes_names.each{|node| hash_result[uri][node] = [get_hash_node(attributes_hash[node])] }
      hash_result
    end
  
    def ContextIndexInstance_to_serialized
	  { self.uri.to_s => {"shdm:index_entries" => self.nodes.map{ |node| {:value => node.to_s} }} }
    end

end