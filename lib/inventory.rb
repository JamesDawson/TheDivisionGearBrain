require 'oj'

class Inventory
  attr_reader :required_items, :items, :vests, :masks, :kneepads, :backpacks, :gloves, :holsters

  def initialize(data_file)
    @required_items = ['vests','masks','kneepads','backpacks','gloves','holsters']
    @vests = []
    @masks = []
    @kneepads = []
    @backpacks = []
    @gloves = []
    @holsters = []

    json = File.read(data_file)
    # puts "json: #{json}"
    @items = Oj.load(json)

    @items.each do |i|
      case i['item_type']
      when 'vest'
        @vests.push(i)
      when 'mask'
        @masks.push(i)
      when 'kneepads'
        @kneepads.push(i)
      when 'backpack'
        @backpacks.push(i)
      when 'gloves'
        @gloves.push(i)
      when 'holster'
        @holsters.push(i)
      end
    end
  end

  def generate_builds_cache(cache_file)
    if File.exist?(cache_file)
      File.delete(cache_file)
    end
    f = File.open(cache_file, 'w')
    begin
      num_builds = find_builds(f, @required_items[0])
    rescue
      #handle the error here
    ensure
      f.close unless f.nil?
    end

    return num_builds
  end

  private 
  def find_builds(cache_file, item_type, items_in_build = [], count = 0)
    got_all_required_items = false
    current_item_type_index = @required_items.index(item_type)
    if current_item_type_index == @required_items.count - 1
      got_all_required_items = true
    else
      next_item_type = @required_items[current_item_type_index + 1]
    end

    send(item_type).each do |i|
      items_in_build.push(i)
      if !got_all_required_items
        count = find_builds(cache_file, next_item_type, items_in_build, count)
      else
        # output current item to cache file
        count += 1
        item_as_json = Oj.dump items_in_build
        cache_file.puts item_as_json
      end
      # remove the last item before looping around to the next
      items_in_build.pop
    end
    return count
  end
end
