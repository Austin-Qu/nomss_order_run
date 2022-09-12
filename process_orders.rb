require 'json'
require_relative 'purchase_order'

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
		unfulfillable_order_ids = []
		purchase_orders = []

		orders = get_orders(order_ids)
		products = get_products

    # iterate through orders and order_items, change order status, create purchase orders
		orders.each do |order|
			fulfilled_order_items = []
			order_items = order['items']

			order_items.each do |order_item|
				product = get_product(order_item)

				if product['quantityOnHand'] >= order_item['quantity']
					fulfilled_order_items << order_item

					if product['quantityOnHand'] - order_item['quantity'] < product['reorderThreshold']
						purchase_order = PurchaseOrder.new({ 
							'productId' => product['productId'],
							'reorderAmount'=> product['reorderAmount']
						})

            purchase_order.create
						existing_purchase_order = purchase_orders.detect {|po| po.access['product_id'] == product['productId']}
						
						# assuming only creating purchase order for the first time meeting reorder threshold
						if existing_purchase_order.nil?
							purchase_orders << purchase_order
							purchase_order.export
						end
					end
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

		# saving updated data file
		File.write('./updated_products_and_orders_' + Time.now.to_i.to_s + '.json', JSON.dump(@data))
		puts 'Unfulfillable order IDs are ' + unfulfillable_order_ids.join(", ")
		# return array of unfulfilled order IDs 
    unfulfillable_order_ids
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

    # return array of all order IDs
		existing_orders
	end
end

fulfill = Fulfillment.new(data)

if ARGV[1]
	fulfill.process_orders(ARGV[1].split(","))
else
	raise 'missing a list of order IDs'
end
