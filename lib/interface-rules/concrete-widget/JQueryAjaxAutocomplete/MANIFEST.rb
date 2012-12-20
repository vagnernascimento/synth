{
  name: "JQueryAjaxAutocomplete",
  version:  "0.0.1",
  description: "HTML autocomplete input field",  
  compatible_abstracts: [ "IndefiniteVariable" ],
  dependencies: [ "HTMLPage" ],
  parameters: [
    {name: "css_class", mandatory: false, data_type: "string"},
    {name: "id", mandatory: false, data_type: "string"},
    {name: "json_source_url", mandatory: true, data_type: "string"},
    {name: "node_json_result_element", mandatory: false, data_type: "string"},
    {name: "search_parameter", mandatory: false, data_type: "string"},
    {name: "hash_result_format", mandatory: false, data_type: "string"},
    
    
  ],
  examples: [
    %q{
		maps_to abstract: "input1", concrete_widget: "JQueryAjaxAutocomplete", 
    params: { json_source_url: "http://ws.geonames.org/searchJSON", 
              node_json_result_element: "['geonames']", 
              search_parameter: "name_startsWith", 
              hash_result_format: "item.name" }
  }
  ]
}  

