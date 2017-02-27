def find_item_score(inventory, item_type, stat, current_score=0)
  last_item_type = false
  
  current_item_type_index = inventory.required_items.index(item_type)
  if current_item_type_index == inventory.required_items.count-1
    last_item_type = true
    # puts 'reached last item type to process'
  else
    next_item_type = inventory.required_items[current_item_type_index + 1]
    # puts "next item type: #{next_item_type}"
  end

  best_score = 0
  inventory.send(item_type).each do |i|
    item_score = i[stat]
    build_score = current_score + item_score
    
    if !last_item_type
      build_score = find_item_score(inventory, next_item_type, stat, build_score)
    end

    if build_score > best_score
      # puts "  better score found: #{item_type} #{build_score} (#{i['name']})"
      best_score = build_score
    end
  end
  return best_score
end