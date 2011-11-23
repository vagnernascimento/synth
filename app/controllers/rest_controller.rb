class RestController < ApplicationController

  def classes
    render :text => RDFS::Class.domain_classes.to_json
  end
  
  def properties
    render :text => RDF::Property.find_all.to_json
  end
  
  def showddd
    render :text => RDFS::Resource.new(params[:id]).direct_properties.to_json
  end
  
  #index http%3A%2F%2Fbase%2384f5cd60-59bc-11e0-b9e1-00264afffe1d
  def index
    
    index = SHDM::Index.find(params[:id])
    #index = SHDM::Index.find('http://base#cd3b1580-59bc-11e0-b9e1-00264afffe1d')
   
    
    @index = index.new({})
    
    #render :text => @index.nodes.first.direct_attributes.inspect
    render :text => @index.entry(@index.nodes.first).attributes_hash["When"].label
  end
  
  def showdd
    @resource          = RDFS::Resource.new(params[:id])
    @current_class_uri = @resource.classes.first.uri
    @domain_classes    = RDFS::Class.domain_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    @meta_classes      = RDFS::Class.meta_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    render :template   => 'rest/show', :layout => false
  end
  
end
