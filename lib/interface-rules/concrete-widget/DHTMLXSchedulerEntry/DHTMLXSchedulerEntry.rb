class DHTMLXSchedulerEntry < ConcreteWidget::WidgetBase
  def initialize(params)
    @content  = params[:content] || ""
    @name = params[:name]
    @id = params[:id]
    @params = params
		@entries = Hash.new
  end
	
	def add_entry(node, value)
		@entries[node] = value
	end
	
	def render
		@parent.add_entry(@entries)
	end
	
end