class MinimumStat
  # This 'non-scoring' rule ensures that a build provides at least a certain value of a given stat
  # e.g. to unlock a weapon talent
  # static method
  def self.process(item_set, parameters)
    score = 0
    stat_name = parameters['stat']
    item_set.each do |i|
      score += i[stat_name]
    end
    return { 'passed' => (score > parameters['min_value']) }
  end
end

class MinimumStat2
  # This 'filtering' rule ensures that a build provides at least a certain value of a given stat
  # e.g. to unlock a weapon talent
  # static method
  def self.process(statistics, parameters)
    stat_name = parameters['stat']
    return { 'passed' => (statistics[stat_name] > parameters['min_value']) }
  end
end

class MaximiseStat
  # This scoring rule simply returns the total value of a given stat provided by a build
  def self.process(item_set, parameters)
    score = 0
    stat_name = parameters['stat']
    item_set.each do |i|
      score += i[stat_name]
    end
    return { 'passed' => true, 'score' => score} 
  end
end