require 'oj'
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

# load the test data
inventory = Inventory.new('gear-list.json')
cache_file = 'cached-gear-permutations.dat'
num_builds = inventory.generate_builds_cache(cache_file)
puts "Generated a cache of all #{num_builds} possible gear item permutations: #{cache_file}"

engine = FilterEngine.new(cache_file)

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
res = engine.process

# render the results in some vaguely useful way
puts "*** Top #{res.size} Builds ***"
res.each do |r|
  puts "\nElectronics: #{r['statistics']['electronics']}"
  puts "Armor: #{r['statistics']['armor']}"
  puts "Stamina: #{r['statistics']['stamina']}"
  puts "Firearms: #{r['statistics']['firearms']}"
  r['items'].each do |i|
    puts "\t#{i['name']} (#{i['armor']} armor)"
  end
end