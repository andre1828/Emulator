# create one number for each instruction profile

class Encoder
  @word = 16 / 8

  def encode(instructions)
    byte_instructions = []
    instructions.each do |instr|
      byte_instructions << to_byte_array(instr)
    end

    byte_instructions
  end

  def to_byte_array(instruction)
    byte_array = []

    if is_loop?(instruction)
      return encode_loop(instruction)
    elsif is_label?(instruction)
      return encode_label(instruction)
    end

    # mnemonic
    byte_array << encode_mnemonic(instruction[0], instruction)

    #first parameter
    if is_register? instruction[1]
      byte_array << encode_register(instruction[1])
    elsif is_mem_address? instruction[1]
      byte_array << encode_mem_address(instruction[1])
    elsif is_integer? instruction[1]
      byte_array << encode_integer(instruction[1])
    else
      raise ArgumentError.new "primeiro parametro invalido em #{instruction}"
    end

    if instruction[2]
      if is_register? instruction[2]
        byte_array << encode_register(instruction[2])
      elsif is_mem_address? instruction[2]
        byte_array << encode_mem_address(instruction[2])
      elsif is_integer? instruction[2]
        byte_array << encode_integer(instruction[2])
      else
        raise ArgumentError.new "segundo parametro invalido em #{instruction}"
      end
    end

    if instruction[3]
      if is_register? instruction[3]
        byte_array << encode_register(instruction[3])
      elsif is_mem_address? instruction[3]
        byte_array << encode_mem_address(instruction[3])
      elsif is_integer? instruction[3]
        byte_array << encode_integer(instruction[3])
      elsif is_loop? instruction[3]
        byte_array << encode_loop(instruction[3])
      else
        raise ArgumentError.new "terceiro parametro invalido em #{instruction}"
      end
    end

    # puts "instruction #{instruction} becomes : #{byte_array}"
    byte_array
  end

  def is_register?(parameter)
    return false if !parameter

    parameter == "A" || parameter == "B" ||
    parameter == "C" || parameter == "D"
  end

  def is_mem_address?(parameter)
    return false if !parameter
    parameter.to_s.start_with? "0x"
  end

  def is_integer?(parameter)
    return false if !parameter
    !parameter.scan(/^([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$/).empty?
  end

  def is_loop?(parameter)
    return false if !parameter
    parameter.include? "jmp"
  end

  def is_label?(parameter)
    return false if !parameter
    parameter[0] == 'lbl'
  end

  def encode_mnemonic(mnemonic, instruction)
    case mnemonic
    when "inc"
      if (is_register? instruction[1])
        1.to_s(2).to_i
      else
        2.to_s(2).to_i
      end
    when "add"
      if ((is_register? instruction[1]) && (is_register? instruction[2]))
        3.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_mem_address? instruction[2]))
        4.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_integer? instruction[2]))
        5.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_mem_address? instruction[2]))
        6.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_register? instruction[2]))
        7.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_integer? instruction[2]))
        8.to_s(2).to_i
      else
        abort "opcao invalida de instrucao add"
      end
    when "mov"
      if ((is_register? instruction[1]) && (is_register? instruction[2]))
        9.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_mem_address? instruction[2]))
        10.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_integer? instruction[2]))
        11.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_mem_address? instruction[2]))
        12.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_register? instruction[2]))
        13.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_integer? instruction[2]))
        14.to_s(2).to_i
      else
        abort "opcao invalida de instrucao mov"
      end
    when "imul"
      if ((is_register? instruction[1]) && (is_register? instruction[2]) && (is_register? instruction[3]))
        15.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_register? instruction[2]) && (is_mem_address? instruction[3]))
        16.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_register? instruction[2]) && (is_integer? instruction[3]))
        17.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_mem_address? instruction[2]) && (is_register? instruction[3]))
        18.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_mem_address? instruction[2]) && (is_integer? instruction[3]))
        19.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_mem_address? instruction[2]) && (is_mem_address? instruction[3]))
        20.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_integer? instruction[2]) && (is_integer? instruction[3]))
        21.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_integer? instruction[2]) && (is_register? instruction[3]))
        22.to_s(2).to_i
      elsif ((is_register? instruction[1]) && (is_integer? instruction[2]) && (is_mem_address? instruction[3]))
        23.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_integer? instruction[2]) && (is_integer? instruction[3]))
        24.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_integer? instruction[2]) && (is_register? instruction[3]))
        25.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_integer? instruction[2]) && (is_mem_address? instruction[3]))
        26.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_mem_address? instruction[2]) && (is_mem_address? instruction[3]))
        27.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_mem_address? instruction[2]) && (is_integer? instruction[3]))
        28.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_mem_address? instruction[2]) && (is_register? instruction[3]))
        29.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_register? instruction[2]) && (is_register? instruction[3]))
        30.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_register? instruction[2]) && (is_mem_address? instruction[3]))
        31.to_s(2).to_i
      elsif ((is_mem_address? instruction[1]) && (is_register? instruction[2]) && (is_integer? instruction[3]))
        32.to_s(2).to_i
      else
        abort "opcao invalida de instrucao imul"
      end
    when "lbl"
      36.to_s(2).to_i
    end
  end

  def encode_register(register)
    case register
    when "A"
      10.to_s(2).to_i
    when "B"
      11.to_s(2).to_i
    when "C"
      12.to_s(2).to_i
    when "D"
      13.to_s(2).to_i
    end
  end

  def encode_mem_address(address)
    address.to_i(16).to_s(2).to_i
  end

  def encode_integer(integer)
    integer.to_i.to_s(2).to_i
  end

  def encode_loop(loop)
    # TODO implement encode loop
    byte_array = []

    if (is_register?(loop[0]) && loop[1] == '<' && is_register?(loop[2]))
      byte_array << 37.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>' && is_register?(loop[2]))
      byte_array << 38.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '<=' && is_register?(loop[2]))
      byte_array << 39.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>=' && is_register?(loop[2]))
      byte_array << 40.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '==' && is_register?(loop[2]))
      byte_array << 41.to_s(2).to_i
    end

    if (is_register?(loop[0]) && is_register?(loop[2]))
      byte_array << encode_register(loop[0])
      byte_array << encode_register(loop[2])
    end

    if (is_register?(loop[0]) && loop[1] == '<' && is_integer?(loop[2]))
      byte_array << 42.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>' && is_integer?(loop[2]))
      byte_array << 43.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '<=' && is_integer?(loop[2]))
      byte_array << 44.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>=' && is_integer?(loop[2]))
      byte_array << 45.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '==' && is_integer?(loop[2]))
      byte_array << 46.to_s(2).to_i
    end

    if (is_register?(loop[0]) && is_integer?(loop[2]))
      byte_array << encode_register(loop[0])
      byte_array << encode_integer(loop[2])
    end

    if (is_mem_address?(loop[0]) && loop[1] == '<' && is_mem_address?(loop[2]))
      byte_array << 47.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>' && is_mem_address?(loop[2]))
      byte_array << 48.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '<=' && is_mem_address?(loop[2]))
      byte_array << 49.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>=' && is_mem_address?(loop[2]))
      byte_array << 50.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '==' && is_mem_address?(loop[2]))
      byte_array << 51.to_s(2).to_i
    end

    if (is_mem_address?(loop[0]) && is_mem_address?(loop[2]))
      byte_array << encode_mem_address(loop[0])
      byte_array << encode_mem_address(loop[2])
    end

    if (is_mem_address?(loop[0]) && loop[1] == '<' && is_integer?(loop[2]))
      byte_array << 52.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>' && is_integer?(loop[2]))
      byte_array << 53.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '<=' && is_integer?(loop[2]))
      byte_array << 54.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>=' && is_integer?(loop[2]))
      byte_array << 55.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '==' && is_integer?(loop[2]))
      byte_array << 56.to_s(2).to_i
    end

    if (is_mem_address?(loop[0]) && is_integer?(loop[2]))
      byte_array << encode_mem_address(loop[0])
      byte_array << encode_integer(loop[2])
    end


    if (is_register?(loop[0]) && loop[1] == '<' && is_mem_address?(loop[2]))
      byte_array << 57.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>' && is_mem_address?(loop[2]))
      byte_array << 58.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '<=' && is_mem_address?(loop[2]))
      byte_array << 59.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '>=' && is_mem_address?(loop[2]))
      byte_array << 60.to_s(2).to_i
    elsif (is_register?(loop[0]) && loop[1] == '==' && is_mem_address?(loop[2]))
      byte_array << 61.to_s(2).to_i
    end

    if (is_register?(loop[0]) && is_mem_address?(loop[2]))
      byte_array << encode_register(loop[0])
      byte_array << encode_mem_address(loop[2])
    end

    if (is_mem_address?(loop[0]) && loop[1] == '<' && is_register?(loop[2]))
      byte_array << 62.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>' && is_register?(loop[2]))
      byte_array << 63.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '<=' && is_register?(loop[2]))
      byte_array << 64.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '>=' && is_register?(loop[2]))
      byte_array << 64.to_s(2).to_i
    elsif (is_mem_address?(loop[0]) && loop[1] == '==' && is_register?(loop[2]))
      byte_array << 66.to_s(2).to_i
    end

    if (is_mem_address?(loop[0]) && is_register?(loop[2]))
      byte_array << encode_mem_address(loop[0])
      byte_array << encode_register(loop[2])
    end

    # jmp value
    byte_array << encode_integer(loop[4])

    byte_array
  end

  def encode_label(label)
    byte_array = []

    byte_array << 36.to_s(2).to_i
    byte_array << encode_integer(label[1])

    byte_array
  end
end
