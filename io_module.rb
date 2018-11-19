class IOModule
  attr_accessor :instructions
  def initialize(bufferSize, bus)
    @interruption = 100_001 # 33
    @bufferSize = bufferSize
    @bus = bus
    @instructions
  end

  def getEncodedInstructions(instructions)
    if instructions.count > @bufferSize
      abort 'Quantidade de instrucoes maior que capacidade do buffer'
    end

    @instructions = instructions
  end

  def send_ram(op)
    # @bus.send_ram [op, 0, @instructions.shift]
    @bus.send_ram [op, @instructions.shift, @instructions.shift, @instructions.shift, @instructions.shift, @instructions.shift]
  end

  def send_interruption
    @bus.send_cpu [@interruption, [@interruption, 0], [@interruption, 1], [@interruption, 10], [@interruption, 11], [@interruption, 100]]
  end
end
