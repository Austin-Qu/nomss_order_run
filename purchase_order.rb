require 'json'

class PurchaseOrder
	def initialize(data)
		@data = data
	end

	def create
		purchase_order_ref = 'PURC' + Time.now.to_i.to_s
		@purchase_order = {
			'purchase_order_ref' => purchase_order_ref,
			'product_id' => @data['productId'],
			'reorder_amount' => @data['reorderAmount']
		}
		@purchase_order
	end

	def export
		puts '==export=='
		File.write("./purchase_order_#{@purchase_order['purchase_order_ref']}_" + Time.now.to_i.to_s + '.json', JSON.dump(@purchase_order), mode: 'a')
	end

	def access
		@data
	end
end
