class CPU

  attr_accessor :A,:B,:C,:D
  def initialize(bus, ram)
    @read_op = 100_010 # 34
    @write_op = 100_011
    @interruption = 100_001 # 33
    @instruction
    @value
    @bus = bus
    @ram = ram
    @A = 0
    @B = 0
    @C = 0
    @D = 0
    @pi
    @cache = [[11, 1010, 1011], [11, 1011, 1100], [11, 1010, 1011], [11, 1010, 1011], [11, 1010, 1011]]
    @ram_to_cache = {0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4}
  end

  def receive_cpu
    received = @bus.receive_cpu
    puts "cpu : received #{received}"
    if received[0] == @interruption
      puts 'cpu : got interruptions'
      interruptions = received[1 .. -1]
      interruptions.each do |interruption|
        instruction_index = interruption[1].to_s.to_i(2)
        if on_cache instruction_index
          cache_index = @ram_to_cache[instruction_index] 
          cached_instruction = @cache[cache_index]
          p decode_instruction(convert_to_decimal cached_instruction)
        else
          puts "\e[96m  instruction is NOT cached \e[0m"
        end
      end
      # if on_cache received[1]
      #   puts "\e[96m  instruction is cached \e[0m"
      #   use_instruction_from_cache(received[1])
      # else
      #   puts "\e[96m  instruction is NOT cached \e[0m"
      #   # @bus.send_ram [@read_op, 0, 3]
      # end
    elsif is_instruction? received # ram sent the requested instruction
      puts "\e[36m received : #{received} \e[0m"
      puts 'cpu : got the requested instruction'
      @instruction = received
      puts "instruction : #{@instruction}"
      if !@pi
        @pi = 0
      else
        @pi += 1
      end
      puts "cpu : current instruction #{@instruction}. current pi \e[91m#{@pi}\e[0m"
      @instruction = convert_to_decimal @instruction
      @instruction = decode_instruction @instruction
      puts "decoded instruction #{@instruction}"
      
    else
      puts 'cpu : got requested value'
      @value = received
    end
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
      decoded_instruction << :imul << (decode_register instruction[1]) <<  (decode_mem_address instruction[2]) << (decode_register instruction[3])
    when 19
      decoded_instruction << :imul << (decode_register instruction[1]) <<  (decode_mem_address instruction[2]) << instruction[3]
    when 20
      decoded_instruction << :imul << (decode_register instruction[1]) <<  (decode_mem_address instruction[2]) << (decode_mem_address instruction[3])
    when 21
      decoded_instruction << :imul << (decode_register instruction[1]) <<  instruction[2] << instruction[3]
    when 22
      decoded_instruction << :imul << (decode_register instruction[1]) <<  instruction[2] << (decode_register instruction[3])
    when 23
      decoded_instruction << :imul << (decode_register instruction[1]) <<  instruction[2] << (decode_mem_address instruction[3])
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
    else
      abort 'Invalid instruction'
      end

    decoded_instruction
  end

  def decode_register(register)
    case register
    when 10
      :A
    when 11
      :B
    when 12
      :C
    when 13
      :D
    else
      abort 'Invalid register'
    end
  end

  def decode_mem_address(mem_address)
    ('0x0' + mem_address.to_s(16)).upcase!
  end

  def mem_address_2_decimal(mem_address)
    mem_address.to_i(16)
  end

  def convert_to_decimal(instruction)
    instruction.map { |piece| piece.to_s.to_i(2) }
  end

  def execute_instruction
    puts "executing #{@instruction}"
    case @instruction[0]
    when :inc
      new_execute_inc @instruction[1]
    when :add
      new_execute_add @instruction[1], @instruction[2]
    when :mov
      new_execute_mov @instruction[1], @instruction[2]
    when :imul
      new_execute_imul @instruction[1], @instruction[2], @instruction[3]
    else
      abort 'Invalid instruction'
    end
  end

  def new_execute_inc(parameter)
    puts "new_execute_inc #parameter : #{parameter}"
    write_value(parameter, (read_value parameter) + 1)
    puts "#### ram size : #{@ram.ram.count}"
  end

  def new_execute_add(fst_parameter, snd_parameter)
    write_value(fst_parameter, (read_value fst_parameter) + (read_value snd_parameter))
  end

  def new_execute_mov(fst_parameter, snd_parameter)
    write_value(fst_parameter, (read_value snd_parameter))
  end

  def new_execute_imul(fst_parameter, snd_parameter, trd_parameter)
    write_value(fst_parameter, (read_value fst_parameter) * (read_value snd_parameter) * (read_value trd_parameter))
  end

  def read_value param
    return param if param.is_a? Integer

    if is_register? param
      instance_variable_get "@#{param}"
    else
      mem_address = mem_address_2_decimal param
      @bus.send_ram [@read_op, mem_address + 4, 0]
      @ram.receive_ram
      receive_cpu
      @value
    end
  end

  def write_value param, value
    puts "##########  write_value : write #{value} to #{param}"
    # abort 'Cannot write to integer' if param.is_a? Integer
    if is_register? param
      instance_variable_set("@#{param}", value)
    else
      mem_address = (param.is_a? String) ? (mem_address_2_decimal param) : param 
      puts " ### writing to mem_address : #{mem_address + 4}"
      @bus.send_ram [@write_op, mem_address + 4, value]
      @ram.receive_ram
    end
  end

  def is_register?(parameter)
    return false unless parameter

    [:A, :B, :C, :D].include? parameter
  end

  def is_mem_address?(parameter)
    return false unless parameter.is_a? String

    parameter.start_with? '0X'
  end

  def is_instruction?(signal)
    signal.is_a?(Array)
  end

  # def is_interruption?(parameter)
  #   parameter.is_a?(Array) && parameter[0] == @interruption
  # end

  def on_cache(index)
    !@ram_to_cache[index].nil? 
  end

  def use_instruction_from_cache(instruction_index)
    puts "\e[30m use_instruction_from_cache : #{@ram[instruction_index]} \e[0m"
    @instruction = convert_to_decimal @instruction
    @instruction = decode_instruction @instruction 
  end
end