class Admin::InstitutionsController < ApplicationController

	layout 'admin'

  def index
    respond_to do |format|
 	    format.html
      format.json { @institutions = Institution.all(:include => [:projects]) }
      format.csv { render :csv => Institution.all, :filename => 'institutions' }

   	end
  end

  def show
    @institution = Institution.find(params[:id])
    if @user
    	@subsidies = @institution.subsidies # Admins get all of them
    else
    	@subsidies = []
    	@institution.subsidies.each do |subsidy|
	    	if subsidy.valid? then @subsidies << subsidy; end
	    end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json # show.json.erb
    end
  end

  def new
    @institution = Institution.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @institution = Institution.find(params[:id])
		@institution.valid?
  end

  # POST /institutions
  # POST /institutions.xml
  def create
    @institution = Institution.new(params[:institution])

    respond_to do |format|
      if @institution.save
      	expire_action :action => :index
        format.html { redirect_to(admin_root_url, :notice => 'Institution was successfully created.') }
        format.xml  { render :xml => @institution, :status => :created, :location => @institution }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /institutions/1
  # PUT /institutions/1.xml
  def update
    @institution = Institution.find(params[:id])

    respond_to do |format|
      if @institution.update_attributes(params[:institution])
      	expire_action :action => :index
        format.html { redirect_to(admin_root_url, :notice => 'Institution was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /institutions/1
  # DELETE /institutions/1.xml
  def destroy
    @institution = Institution.find(params[:id])
    @institution.destroy
   	expire_action :action => :index

    respond_to do |format|
      format.html { redirect_to(admin_root_url) }
      format.xml  { head :ok }
    end
  end
end
