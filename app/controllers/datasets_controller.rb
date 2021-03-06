class DatasetsController < ApplicationController
  
  def index
    @datasets = VOID::Dataset.alpha(DCTERMS::title) || []
  end
    
  # GET /datasets/1
  # GET /datasets/1.xml
  def show
    @dataset = VOID::Dataset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dataset }
    end
  end

  # GET /datasets/new
  # GET /datasets/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dataset }
    end
  end

  # GET /datasets/1/edit
  def edit
    @dataset  = VOID::Dataset.find(params[:id])
  end

  # POST /datasets
  # POST /datasets.xml
  def create
    @dataset = VOID::Dataset.create(ActiveRDF::Namespace.lookup(:base, params[:dataset]['dcterms:title'].downcase), params[:dataset])
    
    respond_to do |format|
      if @dataset.save
        flash[:notice] = 'Concrete Interface was successfully created.'
        format.html { redirect_to(datasets_url) }
        format.xml  { render :xml => @dataset, :status => :created, :location => @dataset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /datasets/1
  # PUT /datasets/1.xml
  def update
		@dataset = VOID::Dataset.find(params[:id])

    respond_to do |format|
      if @dataset.update_attributes(params[:dataset])
        flash[:notice] = 'Dataset was successfully updated.'
        format.html { redirect_to(datasets_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataset.errors, :status => :unprocessable_entity }
      end
    end
	
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.xml
  def destroy
    @dataset = VOID::Dataset.find(params[:id])
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to(datasets_url) }
      format.xml  { head :ok }
    end
  end
 
end
