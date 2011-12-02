var Synth = {
  path : '/rest/',
  Index : function(uri, callback){
    this.uri = uri;
    this.rest_path = 'index';
    this.title = '';
    this.nodes = [];
    this.entries = [];
    this.request_nodes(callback);
  },
  Context : function(){},
};

//--- SYNTH.INDEX METHODS ---

/*--- REQUIRING A NEW INDEX  --- 
   Using ex: var Index = Synth.Index.new('escaped_uri_of_index',
                                          function(){ //callback ; 
                                                      alert('Index title is "'+this.title+ '" and it has '+ this.nodes.length + ' nodes.');
                                                    };
*/ 

Synth.Index.prototype.path = function(){ 
  var url = Synth.path + this.rest_path + (this.uri ? ('/' + this.uri) : '');
  return url
};

Synth.Index.prototype.request_nodes = function(callback){
  var self = this;
  var set_values = function(){
    this.title = self.title;
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
