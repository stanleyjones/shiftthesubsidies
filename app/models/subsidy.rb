include SubsidiesHelper

class Subsidy < ActiveRecord::Base

	validates :amount_usd, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
	validates :amount_original, :numericality => { :greater_than_or_equal_to => 0 }
	validates :currency, :presence => true
	validates :exchange_rate, :presence => true, :numericality => true
	validates :institution, :presence => true
	validates :entity, :presence => true
	validates :project, :presence => true
	validates :kind, :inclusion => {:in => ['Equity','Grant','Guarantee','Loan']}

	belongs_to :institution, :touch => true
	belongs_to :entity, :touch => true
	belongs_to :project, :touch => true

	has_one :sector, :through => :project
	has_one :region, :through => :project
	has_one :institution_group, :through => :institution

	attr_accessible :amount_original, :currency, :amount_usd, :date, :institution_id, :entity_id, :project_id, :kind, :approved, :source, :exchange_rate

	def self.live
		# TODO: Improve the math for fiscal years
		Subsidy.joins(:institution).where(
			"institutions.visible = true AND approved = true AND date > :start_date AND date < :end_date AND amount_original > 0",
			{:start_date => "#{START_YEAR-1}-01-01", :end_date => "#{END_YEAR}-12-31"}
		).uniq
	end

	def amount
		Rails.cache.fetch("subsidy/#{self.id}-#{self.updated_at}/amount") do
			if self.amount_usd
				self.amount_usd
			elsif self.amount_original
				if self.currency == "USD"
					return self.amount_original
				elsif self.exchange_rate != nil
					return self.amount_original * self.exchange_rate * 1.0
				else
					return 0
				end
			else
				return 0
			end
		end
	end

	def in_range?(start_date,end_date)
		if self.date
			return (self.date >= start_date and self.date <= end_date)
		else
			false
		end
	end

	def fiscal_year
		if self.date
			year = self.date.year

			fiscalDate = Date.new(year,self.institution.fiscal_year,1) - 1.day
			fiscalDate = fiscalDate.change(:year => year)
			if self.date > fiscalDate
				year += 1
			end
			year
		else
			0
		end
	end

	def in_category?(category)
		if self.project and self.project.sector and self.project.sector.category
			return self.project.sector.category == category
		else
			false
		end
	end

	# Export CSV via Comma gem

	comma do

		amount_original 'Amount'
		amount_usd 'AmountUSD'
		currency
		date
		fiscal_year
		kind

		institution :name => 'Institution'
		institution :abbreviation => 'Institution Abbreviation'
		institution_group :name => 'Institution Group'
		institution :kind => 'Institution Kind'

		entity :name => 'Entity'
		entity :kind => 'Entity Kind'

		project :name => 'Project'
		project :country
		project :country_code
		project :sector_name
		project :category
		project :access? => 'Energy Access?'

		source

	end

	comma :all do

		approved 'visible'
		date 'date'
		amount_original 'amountOriginal'
		amount_usd 'amountUSD'
		currency 'currency'
		exchange_rate 'XR'
		fiscal_year 'FY'
		kind 'mechanism'

		institution :name => 'institution'
		institution :abbreviation => 'institutionAbbr'
		institution_group :name => 'institutionGroup'
		institution :kind => 'institutionKind'

		project :name => 'project'
		project :name => 'projectInstitutionName'
		project :description => 'projectDesc'

		project :country => 'region'
		project :country_code => 'regionCC'

		project :category => 'category'
		project :sector_name => 'sector'
		project :sector_name => 'stage'
		project :access? => 'access'

		entity :name => 'entity'
		entity :kind => 'entityKind'

		source 'source'

	end

	private

	def update_amount_usd
		usd = self.amount_usd # Keep the original value safe!
		if self.amount_original and self.currency == "USD"
			# The original currency is USD, but amount_usd was never set
			usd = self.amount_original
		elsif self.amount_original and Money::Currency.find(self.currency)
			# The original currency exists in the exchange
			usd = self.amount_original.to_money(currency)
			usd = usd.exchange_to('USD').dollars
		elsif self.currency == "UAC"
			# The original currency is 'UAC' which we do by hand
			usd = self.amount_original * 0.66
		end
		self.amount_usd = usd.to_i
		# self.save
	end
end