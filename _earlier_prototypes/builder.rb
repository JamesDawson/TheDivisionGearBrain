require 'oj'
require '../../lib/helpers.rb'
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

# load the test data
inventory = Inventory.new('../gear-list.json')

puts "Number of items loaded: #{inventory.items.count}"
puts "Number of vests: #{inventory.vests.count}"
puts "Number of masks: #{inventory.masks.count}"
puts "Number of kneepads: #{inventory.kneepads.count}"
puts "Number of backpacks: #{inventory.backpacks.count}"
puts "Number of gloves: #{inventory.gloves.count}"
puts "Number of holsters: #{inventory.holsters.count}"

optimise_for = 'stamina'
puts "looking for optimal #{optimise_for} loadout..."

# Call loop-based logic
optimal_build = find_build_loop(inventory, optimise_for)
puts "Best #{optimise_for} build: #{optimal_build['score']}"
optimal_build['items'].each do |i|
  puts "  #{i['name']} (#{i[optimise_for]})"
end

# Call the recursive logic that just gives the best score
best = find_item_score(inventory, 'vests', optimise_for)
puts "Best #{optimise_for} build: #{best}"

