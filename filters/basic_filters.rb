class EnsureAtLeast
  # This filter ensures that a build provides at least a minimum value of a given stat
  # e.g. to unlock a weapon talent
  def self.process(build_info, parameters)
    stat_name = parameters['stat']

    return { 'passed' => (build_info['statistics'][stat_name] > parameters['min_value']) }
  end
end

class UnlockNamedGearSet
  # This filter ensures that a build includes at least a minimum number of items from the specified named gearset
  # e.g. to unlock a named gearset bonus
  def self.process(build_info, parameters)
    gearset_name = parameters['gearset']
    min_gearset_items = parameters['min_items']

    # how may items in this build belong to the specified named gearset?
    num_gearset_items = (build_info['items'].select{ |i| i['name'].downcase.include? gearset_name }).size

    return { 'passed' => (num_gearset_items >= min_gearset_items) }
  end
end
