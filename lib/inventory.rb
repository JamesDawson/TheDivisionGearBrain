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
end