
input = "C20D7900A012FB9DA43BA00B080310CE3643A0004362BC1B856E0144D234F43590698FF31D249F87B8BF1AD402389D29BA6ED6DCDEE59E6515880258E0040A7136712672454401A84CE65023D004E6A35E914BF744E4026BF006AA0008742985717440188AD0CE334D7700A4012D4D3AE002532F2349469100708010E8AD1020A10021B0623144A20042E18C5D88E6009CF42D972B004A633A6398CE9848039893F0650048D231EFE71E09CB4B4D4A00643E200816507A48D244A2659880C3F602E2080ADA700340099D0023AC400C30038C00C50025C00C6015AD004B95002C400A10038C00A30039C0086002B256294E0124FC47A0FC88ACE953802F2936C965D3005AC01792A2A4AC69C8C8CA49625B92B1D980553EE5287B3C9338D13C74402770803D06216C2A100760944D8200008545C8FB1EC80185945D9868913097CAB90010D382CA00E4739EDF7A2935FEB68802525D1794299199E100647253CE53A8017C9CF6B8573AB24008148804BB8100AA760088803F04E244480004323BC5C88F29C96318A2EA00829319856AD328C5394F599E7612789BC1DB000B90A480371993EA0090A4E35D45F24E35D45E8402E9D87FFE0D9C97ED2AF6C0D281F2CAF22F60014CC9F7B71098DFD025A3059200C8F801F094AB74D72FD870DE616A2E9802F800FACACA68B270A7F01F2B8A6FD6035004E054B1310064F28F1C00F9CFC775E87CF52ADC600AE003E32965D98A52969AF48F9E0C0179C8FE25D40149CC46C4F2FB97BF5A62ECE6008D0066A200D4538D911C401A87304E0B4E321005033A77800AB4EC1227609508A5F188691E3047830053401600043E2044E8AE0008443F84F1CE6B3F133005300101924B924899D1C0804B3B61D9AB479387651209AA7F3BC4A77DA6C519B9F2D75100017E1AB803F257895CBE3E2F3FDE014ABC"

class Sixteen
    attr_reader :version_total
    def initialize(hex)
        @version_total = 0
        @binary = binary(hex)
        @next_bit_start = 0
    end

    def binary(hex)
        hex.chars.map {|char| char.hex.to_s(2).rjust(4, '0') }.join('').split('')
    end

    def parse_packet
        version = @binary[@next_bit_start..(@next_bit_start + 2)].join('').to_i(2)
        @version_total += version
        return if @binary[(@next_bit_start + 3)..(@next_bit_start + 5)].nil?
        type = @binary[(@next_bit_start + 3)..(@next_bit_start + 5)].join('').to_i(2)
        @next_bit_start += 6

        next_bit = @binary[@next_bit_start]
        literals = []
        literal_value = nil
        if type == 4
            loop do
                header = @binary[@next_bit_start + 1..@next_bit_start + 4]
                literals << header.join('')
                should_stop = @binary[@next_bit_start] == '0'
                @next_bit_start += 5
                next_bit = @binary[@next_bit_start]
                break if should_stop
            end
            literal_value = literals.join('').to_i(2)
        else
            length_type_id = next_bit
            @next_bit_start += 1
            length = 0
            subpackets = []
            if length_type_id == '0'
                # 15 bits
                length = 15
                length_of_subpackets = @binary[@next_bit_start..(@next_bit_start + length - 1)].join('').to_i(2)
                @next_bit_start += length
                current_position = @next_bit_start
                while @next_bit_start < (current_position + length_of_subpackets)
                    subpackets << parse_packet
                end
            else
                # 11 bits
                length = 11
                number_of_subpackets = @binary[@next_bit_start..(@next_bit_start + length - 1)].join('').to_i(2)
                @next_bit_start += length
                number_of_subpackets.times do
                    subpackets << parse_packet
                end
            end
            literal_value = find_literal(type, subpackets)
        end
        literal_value
    end

    def find_literal(type, subpackets)
    case type
    when 0
            subpackets.inject(:+)
        when 1
            subpackets.inject(:*)
        when 2
            subpackets.min
        when 3
            subpackets.max
        when 5
            subpackets[0] > subpackets[1] ? 1 : 0 
        when 6
            subpackets[0] < subpackets[1] ? 1 : 0 
        when 7
            subpackets[0] == subpackets[1] ? 1 : 0 
        end
    end
end

packet = Sixteen.new(input)
p packet.parse_packet
p packet.version_total
