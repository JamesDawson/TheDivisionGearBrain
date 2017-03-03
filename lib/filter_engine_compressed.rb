require 'oj'
Dir.glob(File.expand_path("../../filters/*.rb", __FILE__)).each do |plugin|
  require plugin
end

class FilterEngineCompressed
  attr_accessor :items_cache_file, :builds_cache_file, :sort_criteria, :filters, :num_results_to_return, :items
  attr_reader :items, :results

  def initialize(cache_name, sort_criteria = [], filters = [], num_results_to_return = 5)
    @items_cache_file = "#{cache_name}_items.dat"
    @builds_cache_file = "#{cache_name}_builds.dat"
    @filters = filters
    @sort_criteria = sort_criteria
    @num_results_to_return = num_results_to_return
    @items = []
    File.foreach(@items_cache_file) do |line|
      items.push(Oj.load(line))
    end
  end
  
  def process(num_results = @num_results_to_return)
    results = Array.new
    if !@filters.nil?
      puts "Searching build combinations..."
      # process the cache file 1 line at a time
      # whilst the cache file is not valid JSON, each line is a valid JSON object
      File.foreach(@builds_cache_file).with_index do |build_json, build_count|
        build_info = Oj.load(build_json)
        all_filters_passed = true

        # resolve actual build items from the hash_code key
        build_info['items'].each.with_index do |key, index|
          item = @items.select{|j| j['base64_sha1'] == key}
          build_info['items'][index] = item[0]
        end

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
        if build_count % 100000 == 0 then print '.'; $stdout.flush end
        if build_count % 1000000 == 0 then print "#{build_count / 1000000}"; $stdout.flush end
      end
      return { 'count' => build_count, 'results' => results }
    else
      puts "No rules supplied!"
    end
  end
end
