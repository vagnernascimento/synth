class DHTMLXSchedulerComposition < ConcreteWidget::WidgetBase
  def initialize(params)
    @content  = params[:content] || ""
    @css_class = params[:css_class]
    @name = params[:name]
    @id = params[:id]
    @params = params
    @depends_on_ids = params[:depends_on_ids]
		@entries = Array.new
  end
    
  def dependencies
    ["HTMLPage"]
  end
  
  def depends_on_ids
    @depends_on_ids
  end
  
	def add_entry(value)
		@entries << value
	end
	
  def run_dependencies(obj)
		obj.include_js(["/_shared/js/jquery-1.7.2.min.js", "/concrete-widget/#{self.class.to_s}/codebase/dhtmlxscheduler.js", "/concrete-widget/#{self.class.to_s}/codebase/ext/dhtmlxscheduler_timeline.js"])
    obj.include_css(["/concrete-widget/#{self.class.to_s}/codebase/dhtmlxscheduler.css"])
  end
   
end