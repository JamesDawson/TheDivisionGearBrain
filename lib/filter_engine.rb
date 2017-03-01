require 'oj'
Dir.glob(File.expand_path("../../filters/*.rb", __FILE__)).each do |plugin|
  require plugin
end

class FilterEngine
  attr_accessor :data_file, :sort_criteria, :filters, :num_results_to_return
  attr_reader :items, :results

  def initialize(data_file, sort_criteria = [], filters = [], num_results_to_return = 5)
    @data_file = data_file
    @filters = filters
    @sort_criteria = sort_criteria
    @num_results_to_return = num_results_to_return
  end
  
  def process(num_results = @num_results_to_return)
    results = Array.new
    if !@filters.nil?
      # process the cache file 1 line at a time
      # whilst the cache file is not valid JSON, each line is a valid JSON object
      File.foreach(@data_file).with_index do |build_json, build_count|
        build_info = Oj.load(build_json)
        all_filters_passed = true

        @filters.each do |f|
          # dynamically call the 'process' method on the class associated with the current rule/filter
          filter_args = [ build_info, f['parameters'] ]
          res = Object.const_get(f['name']).send('process', *filter_args)
          if !res['passed']
            # abandon the current pipeline as soon as one filter does not pass
            all_filters_passed = false
            break
          end
        end

        # if all filters passed, then we add the build to the current list of top builds
        if all_filters_passed
          results.push(build_info)
          
          # now dynamically construct the sort expression based on the specified criteria
          criteria = []
          @sort_criteria.each do |c|
            criteria.push("-r['statistics']['#{c}']")
          end
          sort_expr = "results.sort_by{|r| [#{criteria.join(',')}]}"

          # execute the sort expression, then truncate the list to only ever be
          # as long as @num_results_to_return - this also drastically improves
          # performance
          results = (eval(sort_expr)).first(@num_results_to_return)
        end
      end
      return results
    else
      puts "No rules supplied!"
    end
  end
end
