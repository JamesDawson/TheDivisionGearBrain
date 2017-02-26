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
    # puts "json: #{json}"
    @items = Oj.load(json)

    @items.each do |i|
      case i['item_type']
      when 'vest'
        @vests.push(i)
      when 'mask'
        @masks.push(i)
      when 'kneepads'
        @kneepads.push(i)
      when 'backpack'
        @backpacks.push(i)
      when 'gloves'
        @gloves.push(i)
      when 'holster'
        @holsters.push(i)
      end
    end
  end
end


inventory = Inventory.new('gear-list.json')

puts "Number of items loaded: #{inventory.items.count}"
puts "Number of vests: #{inventory.vests.count}"
puts "Number of masks: #{inventory.masks.count}"
puts "Number of kneepads: #{inventory.kneepads.count}"
puts "Number of backpacks: #{inventory.backpacks.count}"
puts "Number of gloves: #{inventory.gloves.count}"
puts "Number of holsters: #{inventory.holsters.count}"

puts 'looking for optimal Firearms loadout...'
best = 0
perms = 0
optimal_build = {}
inventory.vests.each do |v|
  inventory.masks.each do |m|
    inventory.kneepads.each do |k|
      inventory.backpacks.each do |b|
        inventory.gloves.each do |g|
          inventory.holsters.each do |h|
            perms += 1
            total_firearms = v['firearms'] + m['firearms'] + k['firearms'] + b['firearms'] + g['firearms'] + h['firearms']            # puts "Current permuation firearms score: #{total_firearms}"
            if total_firearms <= best
              next
            end
            puts 'Found better loadout!'
            best = total_firearms
            optimal_build[:vest] = v
            optimal_build[:mask] = m
            optimal_build[:kneepads] = k
            optimal_build[:backpack] = b
            optimal_build[:golves] = g
            optimal_build[:holster] = h
          end
        end
      end
    end
  end
end

puts "Searched #{perms} permutations"

# validate
optimal_build.each do |k, v|
  if k != :holster && v['main_stat'] != 'firearms'
    puts 'Houston we have a problem!'
  else
    puts "#{k}: #{v['name']}"
  end
end





