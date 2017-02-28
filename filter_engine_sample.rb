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

# setup the pipeline of rules that should be applied to the build permutations
engine.filters.push({ 'name' => 'EnsureAtLeast', 'parameters' => {'stat' => 'firearms', 'min_value' => 3832} })
engine.filters.push({ 'name' => 'EnsureAtLeast', 'parameters' => {'stat' => 'stamina', 'min_value' => 3832} })
engine.sort_criteria = ['electronics','armor','stamina']
engine.num_results_to_return = 5

# execute the rules
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