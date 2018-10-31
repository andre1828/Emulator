require './parser'
require './encoder'
require './io_module'
require './bus'
require './ram'
require './cpu'

word_size = 64
bufferSize = 64
bus_size = 32
ram_size = 128
read_op = 100010
write_op = 100011

instructions = []
File.open('code.c').each do |line|
  instructions << line unless line.start_with? '//'
end

tokens = Parser.new.tokenize instructions

# tokens.each do |t|
#   p t
# end

bytecode = Encoder.new.encode tokens

puts "\n\n"

# bytecode.each do |bt|
#   p bt
# end

bus = Bus.new bus_size
ram = Ram.new ram_size, bus
cpu = CPU.new bus, ram
io_module = IOModule.new bufferSize, bus
io_module.getEncodedInstructions bytecode

# loop
loop {
  break if io_module.instructions.empty?
  puts "\e[92m #{io_module.instructions.count} instructions left \e[0m"
  io_module.send_ram write_op
  ram.receive_ram
  io_module.send_interruption
  cpu.receive_cpu 
  # cpu calls send_ram internally to ask for instruction
  ram.receive_ram
  cpu.receive_cpu # get requested instruction
  cpu.execute_instruction
}

puts <<~HEREDOC 

\e[1m\e[4m\e[36mStatus do emulador\e[0m

\e[4mREGISTRADORES\e[0m
  A : #{cpu.A}
  B : #{cpu.B}
  C : #{cpu.C}
  D : #{cpu.D}

\e[4mMEMORIA\e[0m 
#{ram.ram}

HEREDOC

ram.ram.each_with_index{ |a, index| 
  puts "#{index} : #{a}" 
} 