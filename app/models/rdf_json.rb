module RdfJson
  
  def rdf_to_json
    case self.class.to_s
      when 'IndexEntryDecorator'
        self.IndexEntryDecorator_to_json
      when 'SHDM::ContextIndex::ContextIndexInstance'
        self.ContextIndexInstance_to_json
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
    #         - Resource URI               - property            - hash with value and details more of the property
    
    def IndexEntryDecorator_to_json
      uri = self.uri
      attributes_hash = self.attributes_hash
      hash_result = { uri => {} }
      self.attributes_names.each{|node| hash_result[uri][node] = [{ :value => attributes_hash[node].label.to_s, :type => attributes_hash[node].class.to_s, :url => attributes_hash[node].respond_to?(:target_url) ? attributes_hash[node].target_url : nil }] }
      hash_result
    end
  
    def ContextIndexInstance_to_json
      
	  hash_result = { self.uri.to_s => {"SHDM:entries" => self.nodes.map{ |node| {:value => node.to_s} }} }
	 
    end

end