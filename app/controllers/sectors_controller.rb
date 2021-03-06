class SectorsController < ApplicationController
	skip_before_filter :authorize, :only => [:index, :show]

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json do
      	@sectors = Sector.live
			end # index.json.erb
      format.csv { render :csv => Sector.live, :filename => 'sectors' }
    end
  end

  def show
    @sector = Sector.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json do 
				@projects = @sector.live_projects
			end
    end
  end
end
