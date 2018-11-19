# build emulator in order : parser -> encoder ->  e/s ->  ram ->  cpu

class Parser

  def initialize
    @label_regex = /^(label)\s*(\d{1}|\d{2})$/
    @loop_regex = /\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5]))\s*(>|<|>=|<=|==|!=)\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5]))\s*:\s*(jmp)\s*(\d{1}|\d{2})\s*:\s*(brk)$/
    @inc_regex = /^(inc)\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2}))$/
    @add_regex = /^(add)\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2}))\s*,\s*(?:(A|B|C|D)|(0x+(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5]))$/
    @mov_regex = /^(mov)\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2}))\s*,\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5]))$/
    @imul_regex = /^(imul)\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2}))\s*,\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5])),\s*(?:(A|B|C|D)|(0x(?:[0-9]|[A-F]){2})|([0-9]|[0-9][0-9]|[0-2][0-5][0-5]))$/
  end

  def tokenize lines
    lines.map {|line| extract_tokens line}
  end

  def extract_tokens line
    list_of_strings = []
    
    if (line.scan(@inc_regex)) != []
      list_of_strings = line.scan(@inc_regex)
    elsif line.scan(@add_regex) != []
      list_of_strings = line.scan(@add_regex)
    elsif line.scan(@mov_regex) != []
      list_of_strings = line.scan(@mov_regex)
    elsif line.scan(@imul_regex) != []
      list_of_strings = line.scan(@imul_regex)
    elsif line.scan(@label_regex) != []
      list_of_strings = line.scan(@label_regex)
    elsif line.scan(@loop_regex) != []
      list_of_strings = line.scan(@loop_regex)
    else
      abort "Invalid instruction in line \n'#{line}'"
    end

    list_of_strings
      .flatten
      .select {|token| token != nil} 
      # .map {|token| token.to_sym}
  end
end
