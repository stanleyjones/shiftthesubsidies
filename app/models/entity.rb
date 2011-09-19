class Entity < ActiveRecord::Base

	validates :name, :presence => true
	validates :kind, :inclusion => {:in => ['Company','Government','Group']}
	
	has_many :subsidies
	has_many :projects, :through => :subsidies, :uniq => true
	has_many :institutions, :through => :subsidies, :uniq => true
	
	has_and_belongs_to_many :groups, :class_name => "Entity", :join_table => "entity_groups", :foreign_key => "group_id", :association_foreign_key => "member_id"
	has_and_belongs_to_many :members, :class_name => "Entity", :join_table => "entity_groups", :foreign_key => "member_id", :association_foreign_key => "group_id"

	def self.live
		Entity.all(:include => [:subsidies,:institutions], :conditions => {'subsidies.approved' => true, 'institutions.visible' => true})
	end
	
	def amount_received(collection = self.subsidies)
		amount = 0
		collection.each do |s|
			if s.amount then amount += s.amount; end
		end
		amount
	end
	
	def live_received
 		Rails.cache.fetch("entities/#{self.id}-#{self.updated_at}/live_received", :expires_in => 10.minutes) do
			amount_received(self.subsidies.live)
 		end
	end
	
	def received
		Rails.cache.fetch("entities/#{self.id}-#{self.updated_at}/received", :expires_in => 10.minutes) do
			amount_received
		end
	end
	
	def percent_clean
		Rails.cache.fetch("entities/#{self.id}-#{self.updated_at}/percent_clean", :expires_in => 10.minutes) do
			clean = 0
			self.subsidies.each do |s|
				if s.project and s.project.sector and s.project.sector.category == "Clean"
					clean += s.amount.to_i
				end
			end
			return clean * 1.0 / [amount_received,1].max
		end
	end

	
	def percent_access
		Rails.cache.fetch("entities/#{self.id}-#{self.updated_at}/percent_access", :expires_in => 10.minutes) do
			access = 0
			self.subsidies.each do |s|
				#if s.project and s.project.tags and s.project.tags == "Energy Access"
				if s.project and s.project.energy_access
					access += s.amount
				end
			end
			return access * 1.0 / [amount_received,1].max
		end
	end
			
end