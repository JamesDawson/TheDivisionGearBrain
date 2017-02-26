require 'oj'

class Inventory
  attr_reader :items, :vests, :masks, :kneepads, :backpacks, :gloves, :holsters

  def initialize(data_file)
    @vests = []
    @masks = []
    @kneepads = []
    @backpacks = []
    @gloves = []
    @holsters = []

    json = File.read(data_file)
    puts "json: #{json}"
    @items = Oj::load(json)

    @items.each do |i|
      case i['item_type']
        when 'vest'
          @vests.push(i)
        when 'mask'
          @masks.push(i)
       when 'kneepads'
          @kneepads.push(i)
       when 'backpacks'
          @backpacks.push(i)
       when 'gloves'
          @gloves.push(i)
       when 'holsters'
          @holsters.push(i)
      end
    end
  end
end


inventory = Inventory.new('gear-list.json')

puts "Number of items loaded: #{inventory.items.count}"

