class Project < ActiveRecord::Base

	validates :name, :presence => true
	validates :country, :presence => true
	validates :sector, :presence => true
	
	belongs_to :sector, :touch => true
	has_many :subsidies
	has_many :institutions, :through => :subsidies, :uniq => true
	has_many :entities, :through => :subsidies, :uniq => true

	attr_accessible :name, :country, :description, :notes, :energy_access, :sector_id

	def self.live
		Project.joins(:institutions,:subsidies).where(
			"institutions.visible = true AND subsidies.approved = true AND subsidies.date > :start_date AND subsidies.date < :end_date AND subsidies.amount_original > 0",
			{:start_date => "#{START_YEAR-1}-01-01", :end_date => "#{END_YEAR}-12-31"}
		).uniq
	end
	
	def self.live_by_region(cc)
		Project.joins(:institutions,:subsidies).where(
			"country_code = :region AND institutions.visible = true AND subsidies.approved = true AND subsidies.date > :start_date AND subsidies.date < :end_date AND subsidies.amount_original > 0",
			{:region => cc, :start_date => "#{START_YEAR}-01-01", :end_date => "#{END_YEAR}-12-31"}
		).uniq
	end
				
	def received(start_date=nil, end_date=nil, collection=self.subsidies)
		amount = 0
		collection.each do |s|
 			if start_date.nil? or end_date.nil? or s.in_range?(start_date,end_date)
				amount += s.amount
 			end
		end
		amount
	end

	def access?
		self.energy_access ? self.energy_access : false
	end
	
	def clean?
		self.sector ? self.sector.category == "Clean" : false
	end
	
	def region
		self.country
	end
	
	def country_code
		if cc = Carmen.country_code(self.country) then cc else ""; end
	end

	def sector_name
		self.sector ? self.sector.name : ""
	end
	
	def category
		self.sector ? self.sector.category : "Other"
	end
		
	def icon
		self.sector ? self.sector.icon : "/images/sectors/default.png"
	end
	
	def live_subsidies
		self.subsidies.live
	end

	comma do

		name 'Project Name'
		country 'Project Country'
		country_code 'Project Country Code'
		category 'Project Category'
		sector_name 'Project Sector'
		sector_name 'Project Subsector'
		access? 'Project Energy Access'
		description 'Project Description'

	end
	
end
