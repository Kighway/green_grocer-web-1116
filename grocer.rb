require 'pry'

def consolidate_cart(cart_array)
  consolidated ={}
  cart_array.each do |item_hash|
    item = item_hash.keys.first
    if consolidated.include?(item)
      consolidated[item][:count] += 1
    else
      consolidated[item] = item_hash.values.first.merge({:count => 1})
    end
  end
  consolidated
end

def apply_coupons(consolidated_cart, coupons = [])
  cart_w_coupons = {}
  consolidated_cart.each do |item_name, item_stats|
    total_items, normal_price, clearance  = item_stats[:count], item_stats[:price], item_stats[:clearance]
    applicable_coupons = coupons.select { |coupon| coupon[:item] == item_name }
    unless applicable_coupons.empty?
      coupon_count = applicable_coupons.length
      coupon = applicable_coupons[0]
      items_per_discount, discount_price = coupon[:num], coupon[:cost]
      useable_coupon_count = [total_items / items_per_discount, coupon_count].min
      undiscounted_items = total_items - items_per_discount * useable_coupon_count
      discounted_amount = useable_coupon_count
      cart_w_coupons[item_name + " W/COUPON"] = {:price => discount_price, :clearance => clearance, :count => discounted_amount }
    end
    undiscounted_items ||= total_items
    cart_w_coupons[item_name] = { :price => normal_price, :clearance => clearance, :count => undiscounted_items }
  end
  cart_w_coupons
end

def apply_clearance(cart)
  cart.each do |item_name, item_stats|
    item_stats[:price] = (item_stats[:price] * 0.8).round(2) if item_stats[:clearance]
  end
  cart
end

def checkout(cart, coupons)
  total = 0
  apply_clearance(apply_coupons(consolidate_cart(cart), coupons)).each do |item_name, item_stats|
    total += item_stats[:price]*item_stats[:count]
  end
  total = total > 100.00 ? total*0.90 : total
end
