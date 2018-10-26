# ram has an offset of 4
class Ram

  attr_reader :ram

  def initialize ram_size, bus
    @read_op = 100_010 # 34
    @write_op = 100_011 # 35
    @ram_size = ram_size
    @bus = bus
    @ram = Array.new ram_size, 0
  end

  def is_instruction? param
    param.each do |index|
      return true if index.kind_of?(Array)
    end
    false
  end


  def receive_ram
    received = @bus.receive_ram
    puts "ram received : #{received}" 
    if(is_instruction? received)
      instruction = received
      puts "ram got instruction : #{instruction}"
      operation = instruction.shift
      if operation == @write_op
        puts "ram got request to write instruction"
        instruction.shift # mem address
        # check if mem address is out of reach and if it is, fill array with zeros
        @ram[0,3] = instruction
        # instruction.each do |piece|
        #   @ram << piece
        # end
        puts "ram : #{@ram}"
      elsif operation == @read_op 
        puts "ram got read request"
        address = instruction.shift
        instruction_size = instruction.shift
        puts "ram sending #{@ram[address..instruction_size].flatten} to cpu"
        @bus.send_cpu(@ram[address..instruction_size].flatten)
      else 
        abort "Invalid ram operation"
      end
    else # value
      value = received
      operation = value.shift
      if operation == @write_op
        address = value.shift
        value_to_write = value.shift
        puts "ram got request to write value #{value_to_write}"
        @ram[address] = value_to_write
        puts "ram : #{@ram}"
      elsif operation == @read_op
        address = value.shift
        size = value.shift
        puts "ram got request to read value at address : #{address}"
        @bus.send_cpu @ram[address]
      else
        abort "Invalid ram operation" 
      end
    end
  end
end