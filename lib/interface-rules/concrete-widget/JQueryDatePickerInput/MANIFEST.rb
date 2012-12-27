{
  name: "JQueryDatePickerInput",
  version:  "0.0.2",
	source: "http://jqueryui.com/datepicker",
  description: "Form input with Jquery Date Picker Calendar",  
  compatible_abstracts: [ "IndefiniteVariable" ],
  dependencies: [ "HTMLPage" ],
  parameters: [
    {name: "css_class", mandatory: false, data_type: "string"},
    {name: "id", mandatory: false, data_type: "string"},
		{name: "content", mandatory: false, data_type: "string"},
    {name: "date_format", mandatory: false, data_type: "string", default_value: "yy-mm-dd"},
    
  ],
  examples: [
    %q{
		maps_to abstract: "date1", concrete_widget: "JQueryDatePickerInput", 
    params: { date_format: "yy-mm-dd" }
  }
  ]
}  

