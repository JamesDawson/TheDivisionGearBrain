# require 'json'
require 'oj'

gear_item_types = [:vest, :mask, :kneepads, :backpack, :gloves, :holster]
gear_item_names = [:HighEnd, :AlphaBridge, :Banshee, :DeadEye, :Sentry, :Striker, :Tactician]

module GearRng
  def choose_main_stat
    roll = rand(100)
    main_stat = case
      when roll < 34
        'firearms'
      when roll > 66
        'stamina'
      else
        'electronics'
      end
    return main_stat
  end 
  def generate_stats(main_stat)
    stats = []
    ["firearms","stamina","electronics"].each do |s|
      case
        when s == main_stat
          main_stat_roll = 1114 + rand(1272)
        else
          main_stat_roll = 205
      end
      stats.push(main_stat_roll)
    end
    return stats
  end
end

class GearItem
  include GearRng
  attr_accessor :name, :item_type, :armor, :firearms, :stamina, :electronics
  attr_reader :main_stat

  def initialize(name)
    @name = name
    self.generate_item_stats
  end
end

class VestGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'vest'
    @armor = 1704 + rand(2003-1704)
    @main_stat = choose_main_stat
    @firearms,@stamina,@electronics = generate_stats(@main_stat)
  end
end

class MaskGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'mask'
    @armor = 852 + rand(1001-852)
    @main_stat = choose_main_stat
    @firearms,@stamina,@electronics = generate_stats(@main_stat)
  end
end

class KneepadsGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'kneepads'
    @armor = 1419 + rand(1668-1419)
    @main_stat = choose_main_stat
    @firearms,@stamina,@electronics = generate_stats(@main_stat)
  end
end

class BackpackGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'backpack'
    @armor = 1135 + rand(1334-1135)
    @main_stat = choose_main_stat
    @firearms,@stamina,@electronics = generate_stats(@main_stat)
  end
end

class GlovesGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'gloves'
    @armor = 852 + rand(1001-852)
    @main_stat = choose_main_stat
    @firearms,@stamina,@electronics = generate_stats(@main_stat)
  end
end

class HolsterGearItem < GearItem
  protected
  def generate_item_stats
    @item_type = 'holster'
    @armor = 852 + rand(1001 - 852)
    @firearms = 1114 + rand(1272 - 1114)
    @stamina = 1114 + rand(1272 - 1114)
    @electronics = 1114 + rand(1272 - 1114)
    # derive main_stat
    tmp_stats = Hash.new
    tmp_stats['firearms'] = @firearms
    tmp_stats['stamina'] = @stamina
    tmp_stats['electronics'] = @electronics
    @main_stat = tmp_stats.max_by{|k,v| v}[0]
  end
end

items = []
(1..2).each do
  items.push(VestGearItem.new(gear_item_names.sample))
  items.push(MaskGearItem.new(gear_item_names.sample))
  items.push(KneepadsGearItem.new(gear_item_names.sample))
  items.push(BackpackGearItem.new(gear_item_names.sample))
  items.push(GlovesGearItem.new(gear_item_names.sample))
  items.push(HolsterGearItem.new(gear_item_names.sample))
end

json = (Oj::dump items, :indent => 2, :mode => :compat)
puts json

out_file = "gear-list.json"
f = File.open(out_file, 'w')
begin
  f.write(json)
rescue
  #handle the error here
ensure
  f.close unless f.nil?
end
