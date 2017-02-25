# require 'json'
#require 'oj'

gear_item_types = [:vest, :mask, :kneepads, :backpack, :gloves, :holster]

class GearItem
  attr_accessor :name, :item_type, :armor, :firearms, :stamina, :electronics

  def initialize(name, item_type)

    @name = name
    @item_type = item_type
    @armor = 100 + rand(1000)
    @firearms = 205 + rand(800)
    @stamina = 205 + rand(800)
    @electronics = 205 + rand(800)
  end
end



items = []
(1..2).each do
  gear_item_types.each do |j|
    items.push(GearItem.new('HighEnd', j))
  end
end

items.each do |i|
  puts "#{i.item_type} -> armor: #{i.armor}"
end

#puts Oj::dump items, :indent => 2, :mode => :compat


