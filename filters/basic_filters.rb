class EnsureAtLeast
  # This 'filtering' rule ensures that a build provides at least a certain value of a given stat
  # e.g. to unlock a weapon talent
  # static method
  def self.process(statistics, parameters)
    stat_name = parameters['stat']
    return { 'passed' => (statistics[stat_name] > parameters['min_value']) }
  end
end
