def find_items_recursive(item_type, stat, current_items = [], best_build = {'items' => [], 'score' => 0, 'searched' => 0})
  last_item_type = false
  current_item_type_index = $required_items.index(item_type)
  if current_item_type_index == $required_items.count - 1
    last_item_type = true
  else
    next_item_type = $required_items[current_item_type_index + 1]
  end

  $inventory.send(item_type).each do |i|
    current_items.push(i)

    if !last_item_type
      best_build = find_items_recursive(next_item_type, stat, current_items, best_build)
    else
      build_score = 0
      current_items.each do |s|
        build_score += s[stat]
      end
      if build_score > best_build['score']
        # puts "  better #{stat} score found: #{build_score} (#{i['name']})"
        best_build['score'] = build_score
        best_build['items'] = deep_copy(current_items)
      end
      best_build['searched'] += 1
    end
    current_items.pop
  end
  return best_build
end