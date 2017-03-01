A pet project to learn more about using Ruby outside of config management tools and to aid experimentation with
different builds in the game 'The Division'.

Previous iterations are retained, but the current prototype can be run:

```ruby filter_engine_sample.rb```

You can experiment with changing the criteria used to select builds by:

- editing/adding ```engine.filters.push``` lines in ```filter_engine_sample.rb```
- changing the stats (and their order) included in ```engine.sort_criteria```
- writing new filters (see the ```filters``` folder for examples)

Roadmap

- Model the full set of the gear stats/bonuses
- Model gear mods and their bonuses
- Model named gear sets and their bonuses
- Model weapon talents and their bonuses
- Ideas for easing the process of extracting inventory data from the game
- ???

