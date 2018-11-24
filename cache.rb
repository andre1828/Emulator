class Cache 
	def initialize 
		@cache = [] #[[11, 1010, 1011], [11, 1011, 1100], [11, 1010, 1011], [11, 1010, 1011], [11, 1010, 1011]]
		@ram_to_cache = {} #{ 0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4 }
	end

	def get_cached_instruction(instruction_index)
	    cache_index = @ram_to_cache[instruction_index]
	    cached_instruction = @cache[cache_index]
	    decode_instruction(convert_to_decimal(cached_instruction))
	end

	def on_cache(index)
	    !@ram_to_cache[index].nil?
	end

	def cache_instruction instruction, instruction_index
		@cache[instruction_index] = {instruction: instruction, time: Time.now}
		p "cache_instruction : @cache #{@cache}"
		# TODO check if near 80% capacity
	end
end