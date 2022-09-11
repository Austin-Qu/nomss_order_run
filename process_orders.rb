require 'json'

# file_path = './data.json'
file_path = ARGV[0]

if file_path
	file = File.read(file_path)
	data = JSON.parse(file)
else
	raise 'missing data file'
end

# puts data

class Fulfillment
	def initialize(data)
		@data = data
	end

	def process_orders(data)
	end

	private

	def get_products(data)
	end

	def get_product(products)
	end 

	def get_orders(data)
	end
end
