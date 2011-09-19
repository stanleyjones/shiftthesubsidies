require 'money'
require 'money/bank/google_currency'

module SubsidiesHelper

	Money.default_bank = Money::Bank::GoogleCurrency.new
	Money::Currency::TABLE[:UAC] = {	
		:iso_code        => "UAC",
		:name            => "Units of Account",
		:symbol          => "UA",
		:separator       => ".",
		:delimiter       => ","
	}

	def currency_options_for_select( selected = nil )
		currencies = Money::Currency::TABLE.keys
		currency_options = []
		currencies.collect { |c|
			currency = Money::Currency::TABLE[c]
			currency_options << ["#{currency[:name]} (#{currency[:iso_code]})", currency[:iso_code]]
		}
		#currencies.sort!
		return options_for_select(currency_options, :selected => selected )
	end
	
	def number_to_short( amount )
		return "$#{ number_to_human( amount, :format => "%n%u", :units => {:unit => "USD", :thousand => "k", :million => "M", :billion => "B"} )}"
	end

	def total_awarded( collection = Subsidies.all )
		amount = 0
		collection.each do |s|
			amount += s.amount
		end
		amount
	end

end
