class StaticController < ApplicationController
	skip_before_filter :authorize

	def index
	end

	def national
	end

	def international
	end

	def exploration
	end

	def methodology
	end

	def all
		respond_to do |format|
			format.json do
				@subsidies = Subsidy.live.limit(10)
			end
			format.csv do
				render :csv => Subsidy.all, :filename => 'all', :style => :all
			end
		end
	end

end
