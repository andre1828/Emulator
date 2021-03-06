class Cache
  attr_accessor :ram_to_cache, :write_count, :cache

  def initialize(ram_size)
    @cache = Array.new(ram_size * 0.25)
		@cache_usage_boundary = (@cache.count * 0.80).ceil
		@ram_to_cache = {} #{ 0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4 }
    @write_count
  end

  def get_cached_instruction(instruction_index)
    cache_index = @ram_to_cache[instruction_index]
    @cache[cache_index][:time] = Time.now.nsec 
    cached_instruction = @cache[cache_index][:instruction]
    cached_instruction
    # decode_instruction(convert_to_decimal(cached_instruction))
  end

  def on_cache(index)
    # puts "\e[33m #{@ram_to_cache} , index is #{index} \e[0m"
    !@ram_to_cache[index].nil?
  end

  def cache_instruction(instruction, instruction_index)
    @write_count = @write_count ? @write_count + 1 : 0
    @cache[instruction_index] = {instruction: instruction, time: Time.now.nsec}
    @ram_to_cache[instruction_index] = instruction_index
    # p "cache_instruction : @cache #{@cache}"
    lru(instruction, instruction_index) if @cache.compact.count == @cache_usage_boundary
  end

  def lru instruction, instruction_index
    #  TODO  test method
    timestamps = @cache.map { |i| i[:time] }
    oldest_timestamp_index = timestamps.find_index(timestamps.min)
    @cache[oldest_timestamp_index] = {instruction: instruction, time: Time.now.nsec}
  end

  def convert_to_decimal(instruction)
    puts "cache convert_to_decimal :  #{instruction}"
    instruction.map { |piece| piece.to_s.to_i(2) }
  end

  def decode_instruction(instruction)
    decoded_instruction = []

    mnemonic = instruction[0]

    case mnemonic
    when 1 # inc
      decoded_instruction << :inc << (decode_register instruction[1])
    when 2
      decoded_instruction << :inc << instruction[1]
    when 3 # add
      decoded_instruction << :add << (decode_register instruction[1]) << (decode_register instruction[2])
    when 4
      decoded_instruction << :add << (decode_register instruction[1]) << (decode_mem_address instruction[2])
    when 5
      decoded_instruction << :add << (decode_register instruction[1]) << instruction[2]
    when 6
      decoded_instruction << :add << (decode_mem_address instruction[1]) << (decode_mem_address instruction[2])
    when 7
      decoded_instruction << :add << (decode_mem_address instruction[1]) << decode_register(instruction[2])
    when 8
      decoded_instruction << :add << (decode_mem_address instruction[1]) << instruction[2]
    when 9 # mov
      decoded_instruction << :mov << (decode_register instruction[1]) << (decode_register instruction[2])
    when 10
      decoded_instruction << :mov << (decode_register instruction[1]) << (decode_mem_address instruction[2])
    when 11
      decoded_instruction << :mov << (decode_register instruction[1]) << instruction[2]
    when 12
      decoded_instruction << :mov << (decode_mem_address instruction[1]) << (decode_mem_address instruction[2])
    when 13
      decoded_instruction << :mov << (decode_mem_address instruction[1]) << (decode_register instruction[2])
    when 14
      decoded_instruction << :mov << (decode_mem_address instruction[1]) << instruction[2]
    when 15 # imul
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_register instruction[2]) << (decode_register instruction[3])
    when 16
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_register instruction[2]) << (decode_mem_address instruction[3])
    when 17
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_register instruction[2]) << instruction[3]
    when 18
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_mem_address instruction[2]) << (decode_register instruction[3])
    when 19
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_mem_address instruction[2]) << instruction[3]
    when 20
      decoded_instruction << :imul << (decode_register instruction[1]) << (decode_mem_address instruction[2]) << (decode_mem_address instruction[3])
    when 21
      decoded_instruction << :imul << (decode_register instruction[1]) << instruction[2] << instruction[3]
    when 22
      decoded_instruction << :imul << (decode_register instruction[1]) << instruction[2] << (decode_register instruction[3])
    when 23
      decoded_instruction << :imul << (decode_register instruction[1]) << instruction[2] << (decode_mem_address instruction[3])
    when 24
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << instruction[2] << instruction[3]
    when 25
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << instruction[2] << (decode_register instruction[3])
    when 26
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << instruction[2] << (decode_mem_address instruction[3])
    when 27
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_mem_address instruction[2]) << (decode_mem_address instruction[3])
    when 28
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_mem_address instruction[2]) << instruction[3]
    when 29
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_mem_address instruction[2]) << (decode_register instruction[3])
    when 30
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_register instruction[2]) << (decode_register instruction[3])
    when 31
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_register instruction[2]) << (decode_mem_address instruction[3])
    when 32
      decoded_instruction << :imul << (decode_mem_address instruction[1]) << (decode_register instruction[2]) << instruction[3]
    when 36
      decoded_instruction << :lbl << instruction[1]
    when 37
      decoded_instruction.push :loop ,
                                decode_register(instruction[1]) ,
                                :< ,
                                decode_register(instruction[2]) ,
                                instruction[3]
      binding.pry
    else
      abort "cache class :  Invalid instruction"
    end

    decoded_instruction
  end
end