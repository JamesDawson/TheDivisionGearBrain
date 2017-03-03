require 'oj'
require 'benchmark'
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

# load the test data
# inventory = InventoryCompressed.new('my-gear-list.json')
# db_name = 'gear_db'
cache_name = 'mygear'
# time = Benchmark.measure do
#   num_builds = inventory.generate_builds_cache(cache_name)
# end
# puts "Generated a cache of all #{num_builds} possible gear item combinations: #{cache_name}"
# puts "Time Taken: #{time} seconds - processing rate: #{num_builds / time} builds/sec"

engine = FilterEngineCompressed.new(cache_name)

# setup the pipeline of filters that should be applied to the build permutations
# the order they are specified is the order they are evaluated
# 'filters' are ways to exclude statistics/values that you explicitly don't want
engine.filters.push({ 'name' => 'UnlockNamedGearSet', 'parameters' => {'gearset' => 'deadeye', 'min_items' => 3} })
engine.filters.push({ 'name' => 'EnsureAtLeast', 'parameters' => {'stat' => 'firearms', 'min_value' => 3832} })
engine.filters.push({ 'name' => 'EnsureAtLeast', 'parameters' => {'stat' => 'stamina', 'min_value' => 3832} })

# specify how you want to prioritise the available stats
# 'sort_criteria' are how you tell the tool the stats you care about
engine.sort_criteria = ['electronics','armor','stamina']

# how many potential builds do you want to see
# larger numbers may slow down the processing time
engine.num_results_to_return = 3

# show me the builds!
time = Benchmark.measure do
  res = engine.process
end
puts "Time Taken: #{time} seconds - comparison rate: #{res['count'] / time} builds/sec"

# render the results in some vaguely useful way
puts "*** Top #{res['results'].size} Builds ***"
res['results'].each do |r|
  puts "\nElectronics: #{r['statistics']['electronics']}"
  puts "Armor: #{r['statistics']['armor']}"
  puts "Stamina: #{r['statistics']['stamina']}"
  puts "Firearms: #{r['statistics']['firearms']}"
  r['items'].each do |i|
    puts "\t#{i['name']} (#{i['armor']} armor)"
  end
end