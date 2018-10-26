class CPU

  attr_accessor :A,:B,:C,:D
  def initialize(bus, ram)
    @read_op = 100_010 # 34
    @write_op = 100_011
    @interruption = 100_011 # 33
    @instruction
    @value
    @bus = bus
    @ram = ram
    @A = 2
    @B = 4
    @C = 6
    @D = 8
    @pi
  end

  def receive_cpu
    received = @bus.receive_cpu
    puts "cpu : received #{received} "
    if received[0] == 100_001
      puts 'cpu : got interruption, requesting ram for instructions '
      @bus.send_ram [@read_op, 0, 3]
    elsif is_instruction? received # ram sent the requested instruction
      puts 'cpu : got the requested instruction'
      @instruction = received
      puts "instruction : #{@instruction}"
      if !@pi
        @pi = 0
      else
        @pi += 1
      end
      puts "cpu : current instruction #{@instruction} . current pi #{@pi}"
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
    # puts "decode_mem_address :  #{mem_address}"
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

  # def execute_inc(parameter)
  #   if is_register? parameter
  #     case parameter
  #     when :A
  #       @A += 1
  #       puts " register A : #{@A}"
  #     when :B
  #       @B += 1
  #       puts " register B : #{@B}"
  #     when :C
  #       @C += 1
  #       puts " register C : #{@C}"
  #     when :D
  #       @D += 1
  #       puts " register D : #{@D}"
  #     else
  #       abort 'invalid register'
  #       end
  #   else # mem address
  #     puts "execute_inc : increment address #{parameter}"
  #     parameter += 4
  #     @bus.send_ram [@read_op, parameter, 0] # read value to increment
  #     @ram.receive_ram
  #     receive_cpu
  #     puts "cpu : value to increment : #{@value}"
  #     @bus.send_ram [@write_op, parameter, @value + 1]
  #     @ram.receive_ram
  #   end
  # end

  # def execute_add(fst_parameter, snd_parameter)
  #   if (is_register? fst_parameter) && (is_register? snd_parameter)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{snd_parameter}")

  #     instance_variable_set("@#{fst_parameter}", fst_register_value + snd_register_value)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")}"
  #   elsif (is_register? fst_parameter) && (is_mem_address? snd_parameter)
  #     mem_address = mem_address_2_decimal snd_parameter
  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu

  #     register_value = instance_variable_get("@#{fst_parameter}")

  #     instance_variable_set("@#{fst_parameter}", @value + register_value)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (snd_parameter.is_a? Integer)
  #     register_value = instance_variable_get("@#{fst_parameter}")
  #     instance_variable_set("@#{fst_parameter}", register_value + snd_parameter)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_mem_address? fst_parameter) && (is_mem_address? snd_parameter)
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     @bus.send_ram [@write_op, fst_mem_address + 4, fst_address_value + snd_address_value]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_register? snd_parameter)
  #     fst_mem_address = mem_address_2_decimal fst_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     register_value = instance_variable_get("@#{snd_parameter}")

  #     @bus.send_ram [@write_op, fst_mem_address + 4, fst_address_value + register_value]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (snd_parameter.is_a? Integer)
  #     fst_mem_address = mem_address_2_decimal fst_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@write_op, fst_mem_address + 4, fst_address_value + snd_parameter]
  #     @ram.receive_ram
  #   else
  #     abort 'Invalid parameters'
  #   end
  # end

  # def execute_mov(fst_parameter, snd_parameter)
  #   if (is_register? fst_parameter) && (is_register? snd_parameter)
  #     snd_register_value = instance_variable_get("@#{snd_parameter}")
  #     instance_variable_set("@#{fst_parameter}", snd_register_value)
  #     puts "@#{fst_parameter} is now #{instance_variable_get("@#{fst_parameter}")}"

  #   elsif (is_register? fst_parameter) && (is_mem_address? snd_parameter)
  #     mem_address = mem_address_2_decimal snd_parameter
  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu

  #     instance_variable_set("@#{fst_parameter}", @value)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (snd_parameter.is_a? Integer)
  #     instance_variable_set("@#{fst_parameter}", snd_parameter)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_mem_address? fst_parameter) && (is_mem_address? snd_parameter)
  #     # fst_address_value
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     @bus.send_ram [@write_op, fst_mem_address + 4, snd_address_value]
  #   elsif (is_mem_address? fst_parameter) && (is_register? snd_parameter)
  #     mem_address = mem_address_2_decimal fst_parameter
  #     @bus.send_ram [@write_op, mem_address + 4, instance_variable_get("@#{snd_parameter}")]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (snd_parameter.is_a? Integer)
  #     mem_address = mem_address_2_decimal fst_parameter
  #     @bus.send_ram [@write_op, mem_address + 4, snd_parameter]
  #     @ram.receive_ram
  #   else
  #     abort 'Invalid parameters'
  #   end
  # end

  # def execute_imul(fst_parameter, snd_parameter, trd_parameter)
  #   if (is_register? fst_parameter) && (is_register? snd_parameter) && (is_register? trd_parameter)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{snd_parameter}")
  #     trd_register_value = instance_variable_get("@#{trd_parameter}")

  #     result = fst_register_value * snd_register_value * trd_register_value

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (is_register? snd_parameter) && (is_mem_address? trd_parameter)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{snd_parameter}")

  #     mem_address = mem_address_2_decimal trd_parameter

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = fst_register_value * snd_register_value * address_value

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (is_register? snd_parameter) && (trd_parameter.is_a? Integer)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{snd_parameter}")

  #     result = fst_register_value * snd_register_value * trd_parameter

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (is_mem_address? snd_parameter) && (is_register? trd_parameter)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{trd_parameter}")

  #     mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = fst_register_value * snd_register_value * address_value

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (is_mem_address? snd_parameter) && (trd_parameter.is_a? Integer)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")

  #     mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = fst_register_value * address_value * trd_parameter

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (is_mem_address? snd_parameter) && (is_mem_address? trd_parameter)
  #     register_value = instance_variable_get("@#{fst_parameter}")

  #     fst_mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     snd_mem_address = mem_address_2_decimal trd_parameter

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     result = register_value * fst_address_value * snd_address_value

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (snd_parameter.is_a? Integer) && (trd_parameter.is_a? Integer)
  #     register_value = instance_variable_get("@#{fst_parameter}")

  #     result = register_value * snd_parameter * trd_parameter

  #     instance_variable_set("@#{fst_parameter}", result)
  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (snd_parameter.is_a? Integer) && (is_register? trd_parameter)
  #     fst_register_value = instance_variable_get("@#{fst_parameter}")
  #     snd_register_value = instance_variable_get("@#{trd_parameter}")

  #     result = fst_register_value * snd_register_value * snd_parameter

  #     instance_variable_set("@#{fst_parameter}", result)

  #     puts "register #{fst_parameter} now holds the value #{instance_variable_get("@#{fst_parameter}")} "
  #   elsif (is_register? fst_parameter) && (snd_parameter.is_a? Integer) && (is_mem_address? trd_parameter)
  #     register_value = instance_variable_get("@#{fst_parameter}")
  #     mem_address = mem_address_2_decimal fst_parameter

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = register_value * snd_parameter * address_value

  #     @bus.send_ram [@write_op, mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (snd_parameter.is_a? Integer) && (trd_parameter.is_a? Integer)
  #     mem_address = mem_address_2_decimal fst_parameter

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = address_value * snd_parameter * trd_parameter

  #     @bus.send_ram [@write_op, mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (snd_parameter.is_a? Integer) && (is_register? trd_parameter)
  #     mem_address = mem_address_2_decimal fst_parameter
  #     register_value = instance_variable_get("@#{trd_parameter}")

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = address_value * snd_parameter * register_value

  #     @bus.send_ram [@write_op, mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (snd_parameter.is_a? Integer) && (is_mem_address? trd_parameter)
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal trd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     result = fst_address_value * snd_parameter * snd_mem_address

  #     @bus.send_ram [@write_op, fst_mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_mem_address? snd_parameter) && (is_mem_address? trd_parameter)
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal snd_parameter
  #     trd_mem_address = mem_address_2_decimal trd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     @bus.send_ram [@read_op, trd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     trd_address_value = @value

  #     result = fst_address_value * snd_address_value * trd_address_value

  #     @bus.send_ram [@write_op, fst_mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_mem_address? snd_parameter) && (trd_parameter.is_a? Integer)
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     result = fst_address_value * snd_address_value * trd_parameter

  #     @bus.send_ram [@write_op, fst_mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_mem_address? snd_parameter) && (is_register? trd_parameter)
  #     register_value = instance_variable_get("@#{trd_parameter}")
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal snd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     result = fst_address_value * snd_address_value * register_value
  #     @bus.send_ram [@write_op, fst_mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_register? snd_parameter) && (is_register? trd_parameter)
  #     mem_address = mem_address_2_decimal fst_parameter
  #     fst_register_value = instance_variable_get("@#{snd_parameter}")
  #     snd_register_value = instance_variable_get("@#{trd_parameter}")

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = address_value * fst_register_value * snd_register_value

  #     @bus.send_ram [@write_op, mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_register? snd_parameter) && (is_mem_address? trd_parameter)
  #     register_value = instance_variable_get("@#{snd_parameter}")
  #     fst_mem_address = mem_address_2_decimal fst_parameter
  #     snd_mem_address = mem_address_2_decimal trd_parameter

  #     @bus.send_ram [@read_op, fst_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     fst_address_value = @value

  #     @bus.send_ram [@read_op, snd_mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     snd_address_value = @value

  #     result = fst_address_value * register_value * snd_address_value

  #     @bus.send_ram [@write_op, fst_mem_address + 4, result]
  #     @ram.receive_ram
  #   elsif (is_mem_address? fst_parameter) && (is_register? snd_parameter) && (trd_parameter.is_a? Integer)
  #     mem_address = mem_address_2_decimal fst_parameter
  #     register_value = instance_variable_get("@#{snd_parameter}")

  #     @bus.send_ram [@read_op, mem_address + 4, 0]
  #     @ram.receive_ram
  #     receive_cpu
  #     address_value = @value

  #     result = address_value * register_value * trd_parameter

  #     @bus.send_ram [@write_op, mem_address + 4, result]
  #     @ram.receive_ram
  #   else
  #     abort 'parametros invalidos'
  #   end
  # end

  def new_execute_inc(parameter)
    write_value parameter, (read_value parameter) + 1
    puts "#### ram size : #{@ram.ram.count}"
  end

  def new_execute_add(fst_parameter, snd_parameter)
    write_value fst_parameter, (read_value fst_parameter) + (read_value snd_parameter)
  end

  def new_execute_mov(fst_parameter, snd_parameter)
    write_value fst_parameter, (read_value snd_parameter)
  end

  def new_execute_imul(fst_parameter, snd_parameter, trd_parameter)
    write_value fst_parameter, (read_value fst_parameter) * (read_value snd_parameter) * (read_value trd_parameter)
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
    puts "##########write_value param is integer #{param}" if param.is_a? Integer
    # abort 'Cannot write to integer' if param.is_a? Integer
    if is_register? param
      instance_variable_set("@#{param}", value)
    else
      mem_address = param
      puts " ### writing to mem_address : #{mem_address + 4}"
      @bus.send_ram [@write_op, mem_address + 4, value]
      @ram.receive_ram
    end
  end

  def is_register?(parameter)
    return false unless parameter

    parameter == :A || parameter == :B ||
    parameter == :C || parameter == :D
  end

  # def is_register?(parameter)
  #   return false unless parameter

  #   [:A, :B, :C, :D].include? parameter
  # end

  def is_mem_address?(parameter)
    return false unless parameter.is_a? String

    parameter.start_with? '0X'
  end

  def is_instruction?(signal)
    signal.is_a?(Array)
  end
end
