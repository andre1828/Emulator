# barramento só influencia na checagem por enquanto

class Bus
  def initialize bus_size
    @bus_size = bus_size
    @ram_bus = []
    @cpu_bus = []
  end

  def send_ram instruction
    @ram_bus << instruction
  end

  def send_cpu instruction
    puts "bus : receiving #{instruction} destined to cpu"
    @cpu_bus << instruction
    puts "bus : cpu_bus #{@cpu_bus}"
  end

  def receive_ram
    @ram_bus.shift
  end

  def receive_cpu
    instruction = @cpu_bus.shift
    puts "bus : sending #{instruction} to cpu"
    instruction
  end

end