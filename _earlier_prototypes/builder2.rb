require 'oj'
require '../../lib/helpers.rb'
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

# load the test data
inventory = Inventory.new('../gear-list.json')

optimise_for = 'stamina'

# Call the recursive logic that returns the best build
# inclues simplistic pluggable 'calculation' & 'selection' logic
calc_args = []
calc_args.push('#current_items')
calc_args.push(optimise_for)

select_args = []
select_args.push('#build_score')
select_args.push(optimise_for)
select_args.push('#best_build')
select_args.push('#current_items')

# construct splat object
build_args = []
build_args.push(inventory)
build_args.push(inventory.required_items[0])
build_args.push('calculate_total_stat_and_armor')
build_args.push(calc_args)
build_args.push('optimise_for_armor_then_stat')
build_args.push(select_args)
best_build = find_items_recursive(*build_args)

puts "Best armor build: #{best_build['armor']}, with #{best_build[optimise_for]} #{optimise_for} (from #{best_build['searched']} permutations)"
best_build['items'].each do |i|
  puts "  #{i['name']} (#{i[optimise_for]})"
end