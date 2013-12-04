{
  name: "JQueryAnythingSlider",
  version:  "0.0.1",
	source: "http://plugins.jquery.com/anythingslider/",
  description: "JQuery Widget to slide any collection of HTML content (imagens, text, etc)",  
  compatible_abstracts: [ "CompositeInterfaceElement" ],
  dependencies: [ "HTMLPage" ],
  parameters: [
    {name: "css_class", mandatory: false, data_type: "string"},
    {name: "id", mandatory: false, data_type: "string"},
    {name: "content", mandatory: false, data_type: "string"},
    {name: "collection", mandatory: false, data_type: "array"},
    
    
  ],
  examples: [
    %q{
		maps_to  abstract: "hotel_images", concrete_widget: "JQueryAnythingSlider", 
    params: { 
      collection: hotel[:images], 
      as: :hotel_image 
      }
  }
  ]
}  

