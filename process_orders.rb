require 'json'

# file_path = './data.json'
file_path = ARGV[0]

if file_path
	file = File.read(file_path)
	data = JSON.parse(file)
else
	raise 'missing data file'
end

class Fulfillment
	def initialize(data)
		@data = data
	end

	def process_orders(order_ids)
		puts 'order_ids'
		puts order_ids
		unfulfillable_order_ids = []

		orders = get_orders(order_ids)
		products = get_products

		orders.each do |order|
			fulfilled_order_items = []
			order_items = order['items']

			order_items.each do |order_item|
				product = get_product(order_item)

				if product['quantityOnHand'] >= order_item['quantity']
					fulfilled_order_items << order_item
				end
			end

			current_order = @data['orders'].detect {|o| o['orderId'] == order['orderId']}

			if fulfilled_order_items.size == order_items.size
				current_order['status'] = 'Fulfilled'

				order_items.each do |order_item|
					product = get_product(order_item)
					product['quantityOnHand'] = product['quantityOnHand'] - order_item['quantity']
				end
			else
				current_order['status'] = 'Unfulfillable'
				unfulfillable_order_ids << current_order['orderId']
			end
		end

		File.write('./updated_products_orders_' + Time.now.to_i.to_s + '.json', JSON.dump(@data))

		unfulfillable_order_ids
		# return array of unfulfilled order IDs 
	end

	private

	def get_products
		@data['products']
	end

	def get_product(order_item)
		product_id = order_item['productId']

		current_product = get_products.detect do |product|
			product['productId'] == product_id.to_i
		end

		current_product
	end 

	def get_orders(order_ids)
		existing_orders = []
		orders_data = @data['orders']
		
		order_ids.each do |order_id|
			existing_order = orders_data.detect do |order_data|
				order_id.to_i == order_data['orderId']
			end

			existing_orders << existing_order
		end

		existing_orders
		# return array of all order IDs
	end
end

class PurchaseOrder

end

fulfill = Fulfillment.new(data)
# oids = fulfill.get_orders(data)
# unfulfilable_oids = fulfill.process_orders(oids)
# puts ARGV[1].split(",")
if ARGV[1]
	fulfill.process_orders(ARGV[1].split(","))
end

# puts data