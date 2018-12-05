class IOModule
  attr_accessor :instructions
  def initialize(bufferSize, bus)
    @interruption_queue = []
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
    @bus.send_ram [op, @instructions.shift]
  end

  def send_interruption
    @bus.send_cpu [INTERRUPTION, [INTERRUPTION, 0]]
  end
end
