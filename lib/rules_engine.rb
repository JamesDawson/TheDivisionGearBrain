require 'oj'
Dir.glob(File.expand_path("../../rules/*.rb", __FILE__)).each do |plugin|
  require plugin
end

class RulesEngine
  attr_accessor :data_file, :rules, :num_results_to_return
  attr_reader :items, :results

  def initialize(data_file, rules = [], num_results_to_return = 5)
    @data_file = data_file
    @rules = rules
    @num_results_to_return = num_results_to_return
  end
  
  def process(num_results = 5)
    results = Array.new
    if !@rules.nil?
      # process the cache file 1 line at a time
      # whilst the cache file is noto valid JSON, each line is a valid JSON array object
      File.foreach(@data_file).with_index do |build_json, build_count|
        build_items = Oj.load(build_json)
        all_rules_passed = true
        
        # prepare to store the result from each rule in the pipeline
        rule_results = []
        @rules.each do |r|
          # dynamically call the 'process' method on the class associated with the current rule
          rule_args = [ build_items,r['parameters'] ]
          res = Object::const_get(r['name']).send('process', *rule_args)
          if !res['passed']
            # currently, we abandon the current rules pipeline as soon as one rule does not pass
            all_rules_passed = false
            break
          end
          # store the result from the successful rule
          rule_results.push(res)
        end

        # if all rules passed, then we can need to compare the result from the 'scoring' rule
        # to see if it scores higher than any preceeeding permutation
        # TODO: This is may be too simplistic for richer rule implementations???
        if all_rules_passed
          # make sure we actually have a 'scoring' result
          scoring_results = rule_results.select{|r| !r['score'].nil?}
          if scoring_results.nil? || scoring_results.size == 0
            puts "no score found - you need to have a 'scoring' rule in your pipeline"
          elsif scoring_results.size > 1
            puts "rule pipelines with multiple 'scoring' rules are not currently supported"
          else
            # what is the lowest score in the current 'Top10'?
            bottom_score = results.min_by{|x| x['score']}
            minimum_score = !bottom_score.nil? ? bottom_score['score'] : 0
            
            # did this build permuatation score enough to get in?
            this_score = scoring_results[0]['score']
            if (this_score > minimum_score)
              # if we already have a full 'Top10', eject the lowest scoring entry
              if results.size >= @num_results_to_return
                results.delete_if{|x| x == bottom_score}
              end
              # add thid build permutation to the 'Top10'
              results.push({'build' => build_items, 'score' => this_score})
            end
          end
        end
      end
      return results.sort_by{|r| -r['score']}
    else
      puts "No rules supplied!"
    end
  end    
end
