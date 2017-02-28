require 'oj'
Dir.glob(File.expand_path("../lib/*.rb", __FILE__)).each do |file|
  require file
end

# load the test data
# inventory = Inventory.new('gear-list.json')
cache_file = 'cached-gear-permutations.json'
# num_builds = inventory.generate_builds_cache(cache_file)
# puts "Generated a cache of all #{num_builds} possible gear item permutations: #{cache_file}"

engine = RulesEngine.new(cache_file)

# setup the pipeline of rules that should be applied to the build permutations
engine.rules.push({ 'name' => 'MinimumStat', 'parameters' => {'stat' => 'firearms', 'min_value' => 2000} })
engine.rules.push({ 'name' => 'MinimumStat', 'parameters' => {'stat' => 'stamina', 'min_value' => 3832} })
engine.rules.push({ 'name' => 'MaximiseStat', 'parameters' => {'stat' => 'electronics'} })
engine.num_results_to_return = 3

# execute the rules
res = engine.process()

# render the results in some vaguely useful way
puts "*** Top #{res.size} Builds ***"
res.each do |r|
  puts "\nElectronics: #{r['score']}"
  total_stamina = r['build'].reduce(0){|sum,x| sum + x['stamina'] }
  total_firearms = r['build'].reduce(0){|sum,x| sum + x['firearms'] }
  puts "Stamina: #{total_stamina}"
  puts "Firearms: #{total_firearms}"
  r['build'].each do |i|
    puts "\t#{i['name']} (#{i['armor']})"
  end
end