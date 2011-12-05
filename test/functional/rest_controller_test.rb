require 'test/test_helper'

#jruby -S script/console
#load 'test/functional/rest_controller_test.rb'
#quit #see the results
class RestControllerTest < ActionController::TestCase
   
  test "resource_without_pass_resource_id" do
    get(:resource, {'id' => nil})
    assert_response :success
    assert_equal JSON.parse(@response.body), {}
  end
  
  test "index_without_pass_index_id" do
    get(:index, {'id' => nil})
    assert_response :success
    assert_equal JSON.parse(@response.body), {}
    
  end
  
  test "context_without_pass_context_id" do
    get(:context, {'id' => nil})
    assert_response :success
    assert_equal JSON.parse(@response.body), {}
  end
  
    
  test "index_passing_only_id" do
    index = SHDM::Index.find_all.first
    get(:index, {'id' => index.id, :node => nil})
    
    parsed_response = JSON.parse(@response.body)
    
    assert_response :success
    assert_equal parsed_response[index.id].is_a?(Hash), true 
    assert_equal parsed_response[index.id]['shdm:index_title'].is_a?(Array), true
    assert_equal parsed_response[index.id]['shdm:index_nodes'].is_a?(Array), true
    
  end
  
  test "index_passing_a_node" do
    index = SHDM::Index.find_all.first
    index_instance = index.new
    node = index_instance.nodes.first
    
    get(:index, {'id' => index.uri, :node => node.uri})
    
    parsed_response = JSON.parse(@response.body)
    
    assert_response :success
    assert_equal parsed_response[node.uri].is_a?(Hash), true 
    parsed_response[node.uri].each{|property| assert_equal property.is_a?(Array), true }
    
  end
  
  test "node in context" do
    context = SHDM::Context.find_all.to_a[2]
    context_instance = context.new
    node = context_instance.resources.first
    
    get(:context, {'id' => context.uri, :node => node.uri})
    
    parsed_response = JSON.parse(@response.body)
    
    #puts parsed_response.inspect
    
    assert_response :success
    assert_equal parsed_response[node.uri].is_a?(Hash), true 
    assert_equal parsed_response[node.uri]['context'].first, context.uri 
    assert_equal parsed_response[node.uri]['resource_properties'].is_a?(Array), true
    assert_equal parsed_response[node.uri]['navigational_properties'].is_a?(Array), true
    parsed_response[node.uri]['resource_properties'].each{ |property| assert_equal property.is_a?(Hash), true }
    
  end
  
  test "request_a_shdm_resource" do
    type = "http://xmlns.com/foaf/0.1/Document"
    resource = ActiveRDF::ObjectManager.construct_class(type).find_all.first
    
    get(:resource, {'id' => resource.id})
    
    parsed_response = JSON.parse(@response.body)
    
    #puts parsed_response.inspect
    
    assert_response :success
    assert_equal parsed_response[resource.uri].is_a?(Hash), true 
    assert_equal parsed_response[resource.uri]['resource_properties'].is_a?(Array), true
    parsed_response[resource.uri]['resource_properties'].each{ |property| assert_equal property.is_a?(Hash), true }
    
  end
  
end
