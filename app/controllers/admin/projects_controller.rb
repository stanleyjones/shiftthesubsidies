class Admin::ProjectsController < ApplicationController
	
	layout 'admin'
	# cache_sweeper :project_sweeper, :only => [:create, :update, :destroy]

  def index
  	if params[:sector_id] and @sector = Sector.find(params[:sector_id])
  		@projects = @sector.projects
  	else
	    @projects = Project.all
		end
		
    respond_to do |format|
      format.html # index.html.erb
      format.json # index.json.erb
      format.csv { render :csv => Project.all, :filename => 'projects' }
    end
  end

  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @project = Project.find(params[:id])
    @project.valid?
  end

  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to(admin_root_url, :notice => 'Project was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to(admin_root_url, :notice => 'Project was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    respond_to do |format|
      format.html { redirect_to(admin_root_url) }
    end
  end
end
