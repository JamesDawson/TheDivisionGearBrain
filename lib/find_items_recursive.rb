def find_items_recursive(inventory, item_type, stat, calculation, current_items = [], best_build = {'items' => [], 'score' => 0, 'searched' => 0})
  last_item_type = false
  current_item_type_index = inventory.required_items.index(item_type)
  if current_item_type_index == inventory.required_items.count - 1
    last_item_type = true
  else
    next_item_type = inventory.required_items[current_item_type_index + 1]
  end

  inventory.send(item_type).each do |i|
    current_items.push(i)

    if !last_item_type
      best_build = find_items_recursive(inventory, next_item_type, stat, calculation, current_items, best_build)
    else
      best_build['searched'] += 1

      # scoring implementation begins here
      #
      # 1. calculate the score (e.g. amount of firearms)
      # 2. compare score to current 'best'
      #
      build_score = self.send(calculation, *[current_items, stat])
      
      if build_score > best_build['score']
        # puts "  better #{stat} score found: #{build_score} (#{i['name']})"
        best_build['score'] = build_score
        best_build['items'] = deep_copy(current_items)
      end

    end
    current_items.pop
  end
  return best_build
end

#
# Pluggable version of the original logic
#
def calculate_total_stat(items, stat)
  score = 0
  items.each do |i|
    score += i[stat]
  end
  return score
end
