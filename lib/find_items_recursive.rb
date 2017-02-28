def find_items_recursive(inventory, item_type, calculation, calculation_args, selection, selection_args, current_items = [], best_build = {})
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
      best_build = find_items_recursive(inventory, next_item_type, calculation, calculation_args, selection, selection_args, current_items, best_build)
    else
      if best_build['searched'].nil?
        best_build['searched'] = 0
      end
      best_build['searched'] += 1

      # scoring implementation begins here
      #
      # 1. calculate the score (e.g. amount of firearms)
      # 2. compare score to current 'best'
      #
      calculation_args_values = []
      calculation_args.each do |c|
        if c.start_with?('#')
          calculation_args_values.push(eval(c.tr('#','')))
        else
          calculation_args_values.push(c)
        end
      end
      build_score = self.send(calculation, *calculation_args_values)

      # apply the criteria to the result of the calculation
      selection_args_values = []
      selection_args.each do |c|
        if c.start_with?('#')
          selection_args_values.push(eval(c.tr('#','')))
        else
          selection_args_values.push(c)
        end
      end
      best_build = self.send(selection, *selection_args_values)
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

def calculate_total_stat_and_armor(items, stat)
  score = {'armor' => 0, "#{stat}" => 0}
  items.each do |i|
    score['armor'] += i['armor']
    score[stat] += i[stat]
  end
  return score
end



def is_score_higher(score, best_build, items)
  if best_build['score'].nil?
    best_build['score'] = 0
  end
  if score > best_build['score']
    best_build['score'] = score
    best_build['items'] = deep_copy(items)
  end
  return best_build
end


# optimise for armor and a specified stat
# experimenting with different structure 'score'
def optimise_for_armor_then_stat(score, stat, best_build, items)
  if best_build['score'].nil?
    best_build['score'] = 0
  end
  if best_build[stat].nil?
    best_build[stat] = 0
  end
  if best_build['armor'].nil?
    best_build['armor'] = 0
  end

  if score['armor'] > best_build['armor']
    best_build['armor'] = score['armor']
    best_build[stat] = score[stat]
    best_build['items'] = deep_copy(items)
  end

  return best_build
end
