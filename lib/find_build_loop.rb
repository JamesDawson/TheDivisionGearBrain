def find_build_loop(optimise_for)
  best = 0
  searched = 0
  optimal_build = {'score' => 0, 'items' => {}}
  $inventory.vests.each do |v|
    $inventory.masks.each do |m|
      $inventory.kneepads.each do |k|
        $inventory.backpacks.each do |b|
          $inventory.gloves.each do |g|
            $inventory.holsters.each do |h|
              searched += 1
              total = v[optimise_for] + m[optimise_for] + k[optimise_for] + b[optimise_for] + g[optimise_for] + h[optimise_for]            # puts "Current permuation firearms score: #{total_firearms}"
              if total > optimal_build['score']
                # puts 'Found better loadout!'
                optimal_build['score'] = total
                optimal_build['items'] = []
                optimal_build['items'].push(v)
                optimal_build['items'].push(m)
                optimal_build['items'].push(k)
                optimal_build['items'].push(b)
                optimal_build['items'].push(g)
                optimal_build['items'].push(h)
              end
            end
          end
        end
      end
    end
  end
  puts "done searching #{searched} combinations"
  return optimal_build
end
