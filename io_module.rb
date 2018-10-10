class IOModule
  attr_accessor :instructions
  def initialize bufferSize, bus
    @interruption = 100001 # 33
    @bufferSize = bufferSize
    @bus = bus
    @instructions
  end

  def getEncodedInstructions instructions
    if instructions.count > @bufferSize
      abort "Quantidade de instrucoes maior que capacidade do buffer" 
    end

    @instructions = instructions 
  end

  def send_ram op
    @bus.send_ram [op, 0, @instructions.shift]
  end

  def send_interruption 
    @bus.send_cpu [@interruption, 0, 100]
  end
end