class RestController < ApplicationController

  def classes
    render :text => RDFS::Class.domain_classes.to_json
  end
  
  def properties
    render :text => RDF::Property.find_all.to_json
  end
  #http://localhost:3000/rest/index/http%3A%2F%2Fbase%2384f5cd60-59bc-11e0-b9e1-00264afffe1d?entry=http%3A%2F%2Fdata.semanticweb.org%2Fconference%2Fwww%2F2011%2Fevent/ps-03
  def index
    #cleaning extra parameters
    params.delete(:controller)
    params.delete(:action)

    index_id = params.delete(:id)
    index = SHDM::Index.find(index_id) unless index_id.nil?
    index = index.nil? ? SHDM::Index.find_all.first : index

    new_params = {}
    params.each{ |i,v| new_params[i] = v.is_a?(Hash) ? RDFS::Resource.new(v["resource"]) : v }
    new_params.delete('authenticity_token')

    index = index.new(new_params)
		result = ( params[:node].nil? ? index : index.entry(RDFS::Resource.new(params[:node])) ).serialize
    
    respond_to do |format|
      format.json  { render :json => result }
      format.text { render :text => result.inspect }
      #format.xml  { render :xml => result }
    end
  end
 
 
  def context
    params.delete(:controller)
    params.delete(:action)

    context_id = params.delete(:id)
    node_id     = params.delete(:node)
    context      = SHDM::Context.find(context_id)

    new_params = {}
    params.each{ |i,v| new_params[i] = v.is_a?(Hash) ? RDFS::Resource.new(v["resource"]) : v }
    new_params.delete('authenticity_token')

    context   = context.new(new_params)
    result = ( node_id.nil? ? context : context.node(RDFS::Resource.new(node_id)) ).serialize
    #result = ( node_id.nil? ? context : context.node(RDFS::Resource.new(node_id)) )
    #render :text => result.context.resources.class.inspect
    respond_to do |format|
      format.json  { render :json => result }
      format.text { render :text => result.inspect }
      #format.xml  { render :xml => result }
    end
    
    
  end
  
end
