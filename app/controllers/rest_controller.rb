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
  
  #http://localhost:3000/rest/index/http%3A%2F%2Fbase%2384f5cd60-59bc-11e0-b9e1-00264afffe1d?entry=http%3A%2F%2Fdata.semanticweb.org%2Fconference%2Fwww%2F2011%2Fevent/ps-03
  def index
    unless params[:id].nil?
		index = SHDM::Index.find(params[:id]).new
		result = params[:entry].nil? ? index : index.entry(RDFS::Resource.new(params[:entry])) 
		#render :text => index.class.to_s
		render :text => result.rdf_to_json.to_json
	end
  end
  
  def showdd
    @resource          = RDFS::Resource.new(params[:id])
    @current_class_uri = @resource.classes.first.uri
    @domain_classes    = RDFS::Class.domain_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    @meta_classes      = RDFS::Class.meta_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    render :template   => 'rest/show', :layout => false
  end
  
end
