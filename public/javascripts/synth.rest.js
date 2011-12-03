var Synth = {
  path : '/rest/',
  Index : function(uri, callback){
    this.uri = uri;
    this.rest_path = 'index';
    this.title = [];
    this.name = [];
    this.nodes = [];
    this.entries = [];
    this.request_nodes(callback);
  },
  Context : function(uri, callback){
    this.uri = uri;
    this.rest_path = 'context';
    this.name = [];
    this.title = [];
    this.resources = [];
    this.nodes = [];
    this.request_resources(callback);
  },
  ContextInstance : function(uri, callback){
    this.uri = uri;
    this.rest_path = 'context';
    this.context = [];
    this.label = [];
    this.resource_properties = [];
    this.navigational_properties = [];
    this.request(callback);
  },
};
//---------------------------------------------------------------------------------
//--- SYNTH.INDEX METHODS ---
//---------------------------------------------------------------------------------

//--- REQUIRING A NEW INDEX  --- 
//   Using ex: var Index = Synth.Index.new('escaped_uri_of_index',
//                                          function(){ //callback ; 
//                                                      alert('Index title is "'+this.title+ '" and it has '+ this.nodes.length + ' nodes.');
//                                                    };

Synth.Index.prototype.path = function(){ 
  var url = Synth.path + this.rest_path + (this.uri ? ('/' + this.uri) : '');
  return url
};

Synth.Index.prototype.request_nodes = function(callback){
  var self = this;
  var set_values = function(){
    this.title = self.title;
    this.name = self.name;
    this.nodes = self.nodes;
  }
  $.getJSON(this.path(), 
    function(data) {
      $.each(data, function(idx, value){
        self.title = value['shdm:index_title'];
        self.nodes = value["shdm:index_nodes"];
      });
      set_values();
    if(callback){callback.call(self);}
  });
}

// --- Using ex.: this.foreach_node( function(key, value) ); ---
Synth.Index.prototype.foreach_node = function(run_on_the_node){
  $.each(this.nodes, run_on_the_node);
}
Synth.Index.prototype.request_entry = function(entry_url, run_on_the_entry){
  $.getJSON(entry_url, run_on_the_entry);
}

Synth.Index.prototype.request_entries = function(run_on_the_entry){
  var path = this.path();
  var request_entry = this.request_entry
  this.foreach_node(function(key, node){
      var entry_url = path + ( path.match(/[?]/) ? '&': '?' ) + 'node='+node.value;
      request_entry(entry_url, run_on_the_entry)
    });
}
//---------------------------------------------------------------------------------
//--- SYNTH.CONTEXT METHODS ---
//---------------------------------------------------------------------------------

//--- REQUIRING A NEW CONTEXT  --- 
//   Using ex: var Index = Synth.Context.new('escaped_uri_of_context',
//                                          function(){ //callback ; 
//                                                      alert('Context title is "'+this.title+ '" and it has '+ this.resources.length + ' resources.');
//   

Synth.Context.prototype.path = function(){ 
  var url = Synth.path + this.rest_path + (this.uri ? ('/' + this.uri) : '');
  return url
};

Synth.Context.prototype.request_resources = function(callback){
  var self = this;
  var set_values = function(){
    this.title = self.title;
    this.resources = self.resources;
  }
  $.getJSON(this.path(), 
    function(data) {
      $.each(data, function(idx, value){
        self.title = value['shdm:context_title'];
        self.name = value['shdm:context_name'];
        self.resources = value["shdm:context_resources"];
      });
      set_values();
    if(callback){callback.call(self);}
  });
}

// --- Using ex.: this.foreach_node( function(key, value) ); ---
Synth.Context.prototype.foreach_resource = function(run_on_the_resource){
  $.each(this.resources, run_on_the_resource);
}

Synth.Context.prototype.request_node = function(node_url, run_on_the_node){
  $.getJSON(node_url, run_on_the_node);
}

//---------------------------------------------------------------------------------
//--- SYNTH.ContextInstance METHODS ---
//---------------------------------------------------------------------------------

//--- REQUIRING A NEW CONTEXT INSTANCE  --- 
//   Using ex: var Index = Synth.Context.new('escaped_uri_of_context_instance',
//                                          function(){ //callback ; 
//                                                      alert('Context instance has '+ this.resource_properties.length + ' resources properties.');
//   

Synth.ContextInstance.prototype.path = function(){ 
  var url = Synth.path + this.rest_path + (this.uri ? ('/' + this.uri) : '');
  return url
};

Synth.ContextInstance.prototype.request = function(callback){
  var self = this;
  var set_values = function(){
    this.label = self.label;
    this.resource_properties = self.resource_properties;
    this.navigational_properties = self.navigational_properties;
  }
  $.getJSON(this.path(), 
    function(data) {
      $.each(data, function(idx, value){
        self.label = value['label'];
        self.resource_properties = value['resource_properties'];
        self.navigational_properties = value['navigational_properties'];
      });
      set_values();
    if(callback){callback.call(self);}
  });
}
