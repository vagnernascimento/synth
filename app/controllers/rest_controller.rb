class RestController < ApplicationController

  def classes
    render :text => RDFS::Class.domain_classes.to_json
  end
  
  def properties
    render :text => RDF::Property.find_all.to_json
  end
  
  def show
    render :text => RDFS::Resource.new(params[:id]).to_json
  end
  def showddd
    @resource          = RDFS::Resource.new(params[:id])
    @current_class_uri = @resource.classes.first.uri
    @domain_classes    = RDFS::Class.domain_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    @meta_classes      = RDFS::Class.meta_classes.sort{|a,b| a.compact_uri <=> b.compact_uri }
    render :template   => 'resources/show'
  end
  
end
