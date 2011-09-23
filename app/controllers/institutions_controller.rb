class InstitutionsController < ApplicationController
	skip_before_filter :authorize, :only => [:index, :show, :graph]
	#caches_action :show

  def index
  
		start_year = params[:s] || START_YEAR
		end_year = params[:e] || params[:s] || END_YEAR
  	@start_date = Date.civil(start_year.to_i,1,1)
  	@end_date = Date.civil(end_year.to_i,12,31)
  	
		@institutions = Institution.where(:visible => true)
    respond_to do |format|
 	    format.html do # index.html.erb
 	    	if request.xhr?
 	    		render :partial => "animated_bubbles"
 	    	end
 	    end
      format.json # index.json.erb
   	end
  end

  def show
		start_year = params[:s] || START_YEAR
		end_year = params[:e] || params[:s] || END_YEAR
  	@start_date = Date.civil(start_year.to_i,1,1)
  	@end_date = Date.civil(end_year.to_i,12,31)

    @institution = Institution.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
      	@projects = @institution.live_projects
			end
    end
  end
end
