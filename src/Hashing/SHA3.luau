--[=[
	Cryptography library: Keccak/SHA-3
	
	Return type: string
	Example usage:
		local Message = buffer.fromstring("Hello World")
		
		local Result1 = SHA3_256(Message)
		local Result2 = SHAKE128(Message, 32)
--]=]

--!native
--!optimize 2
--!strict

local OUTPUT_BUFFER = buffer.create(64)
local LOW_ROUND, HIGH_ROUND = buffer.create(96), buffer.create(96) do
	local HighFactorKeccak = 0
	local ShiftRegister = 29
	local function GetNextBit(): number
		local Result = ShiftRegister % 2
		ShiftRegister =  bit32.bxor((ShiftRegister - Result) // 2, 142 * Result)

		return Result
	end

	for Index = 0, 23 do
		local LowValue: number, Multiplier: number = 0, nil

		for _ = 1, 6 do
			Multiplier = if Multiplier then Multiplier * Multiplier * 2 else 1
			LowValue += GetNextBit() * Multiplier
		end

		local HighValue = GetNextBit() * Multiplier
		buffer.writeu32(HIGH_ROUND, Index * 4, HighValue)
		buffer.writeu32(LOW_ROUND, Index * 4, LowValue + HighValue * HighFactorKeccak)
	end
end

local function Keccak(LanesLow: buffer, LanesHigh: buffer, InputBuffer: buffer, Offset: number, Size: number, BlockSizeInBytes: number)
	local QuadWordsQuantity = BlockSizeInBytes // 8
	local RCHigh, RCLow = HIGH_ROUND, LOW_ROUND

	for Position = Offset, Offset + Size - 1, BlockSizeInBytes do
		for Index = 0, (QuadWordsQuantity - 1) * 4, 4 do
			local BufferPos = Position + Index * 2

			buffer.writeu32(LanesLow, Index, bit32.bxor(
				buffer.readu32(LanesLow, Index),
				buffer.readu32(InputBuffer, BufferPos)
			))
			
			buffer.writeu32(LanesHigh, Index, bit32.bxor(
				buffer.readu32(LanesHigh, Index),
				buffer.readu32(InputBuffer, BufferPos + 4)
			))
		end

		local Lane01Low, Lane01High = buffer.readu32(LanesLow, 0), buffer.readu32(LanesHigh, 0)
		local Lane02Low, Lane02High = buffer.readu32(LanesLow, 4), buffer.readu32(LanesHigh, 4)
		local Lane03Low, Lane03High = buffer.readu32(LanesLow, 8), buffer.readu32(LanesHigh, 8)
		local Lane04Low, Lane04High = buffer.readu32(LanesLow, 12), buffer.readu32(LanesHigh, 12)
		local Lane05Low, Lane05High = buffer.readu32(LanesLow, 16), buffer.readu32(LanesHigh, 16)
		local Lane06Low, Lane06High = buffer.readu32(LanesLow, 20), buffer.readu32(LanesHigh, 20)
		local Lane07Low, Lane07High = buffer.readu32(LanesLow, 24), buffer.readu32(LanesHigh, 24)
		local Lane08Low, Lane08High = buffer.readu32(LanesLow, 28), buffer.readu32(LanesHigh, 28)
		local Lane09Low, Lane09High = buffer.readu32(LanesLow, 32), buffer.readu32(LanesHigh, 32)
		local Lane10Low, Lane10High = buffer.readu32(LanesLow, 36), buffer.readu32(LanesHigh, 36)
		local Lane11Low, Lane11High = buffer.readu32(LanesLow, 40), buffer.readu32(LanesHigh, 40)
		local Lane12Low, Lane12High = buffer.readu32(LanesLow, 44), buffer.readu32(LanesHigh, 44)
		local Lane13Low, Lane13High = buffer.readu32(LanesLow, 48), buffer.readu32(LanesHigh, 48)
		local Lane14Low, Lane14High = buffer.readu32(LanesLow, 52), buffer.readu32(LanesHigh, 52)
		local Lane15Low, Lane15High = buffer.readu32(LanesLow, 56), buffer.readu32(LanesHigh, 56)
		local Lane16Low, Lane16High = buffer.readu32(LanesLow, 60), buffer.readu32(LanesHigh, 60)
		local Lane17Low, Lane17High = buffer.readu32(LanesLow, 64), buffer.readu32(LanesHigh, 64)
		local Lane18Low, Lane18High = buffer.readu32(LanesLow, 68), buffer.readu32(LanesHigh, 68)
		local Lane19Low, Lane19High = buffer.readu32(LanesLow, 72), buffer.readu32(LanesHigh, 72)
		local Lane20Low, Lane20High = buffer.readu32(LanesLow, 76), buffer.readu32(LanesHigh, 76)
		local Lane21Low, Lane21High = buffer.readu32(LanesLow, 80), buffer.readu32(LanesHigh, 80)
		local Lane22Low, Lane22High = buffer.readu32(LanesLow, 84), buffer.readu32(LanesHigh, 84)
		local Lane23Low, Lane23High = buffer.readu32(LanesLow, 88), buffer.readu32(LanesHigh, 88)
		local Lane24Low, Lane24High = buffer.readu32(LanesLow, 92), buffer.readu32(LanesHigh, 92)
		local Lane25Low, Lane25High = buffer.readu32(LanesLow, 96), buffer.readu32(LanesHigh, 96)

		for RoundIndex = 0, 92, 4 do
			local Column1Low, Column1High = bit32.bxor(Lane01Low, Lane06Low, Lane11Low, Lane16Low, Lane21Low), bit32.bxor(Lane01High, Lane06High, Lane11High, Lane16High, Lane21High)
			local Column2Low, Column2High = bit32.bxor(Lane02Low, Lane07Low, Lane12Low, Lane17Low, Lane22Low), bit32.bxor(Lane02High, Lane07High, Lane12High, Lane17High, Lane22High)
			local Column3Low, Column3High = bit32.bxor(Lane03Low, Lane08Low, Lane13Low, Lane18Low, Lane23Low), bit32.bxor(Lane03High, Lane08High, Lane13High, Lane18High, Lane23High)
			local Column4Low, Column4High = bit32.bxor(Lane04Low, Lane09Low, Lane14Low, Lane19Low, Lane24Low), bit32.bxor(Lane04High, Lane09High, Lane14High, Lane19High, Lane24High)
			local Column5Low, Column5High = bit32.bxor(Lane05Low, Lane10Low, Lane15Low, Lane20Low, Lane25Low), bit32.bxor(Lane05High, Lane10High, Lane15High, Lane20High, Lane25High)

			local DeltaLow, DeltaHigh = bit32.bxor(Column1Low, Column3Low * 2 + (bit32.bor(Column3High, 0) - Column3High % 2147483648) // 2147483648), bit32.bxor(Column1High, Column3High * 2 + (bit32.bor(Column3Low, 0) - Column3Low % 2147483648) // 2147483648)
			local Temp0Low, Temp0High = bit32.bxor(DeltaLow, Lane02Low), bit32.bxor(DeltaHigh, Lane02High)
			local Temp1Low, Temp1High = bit32.bxor(DeltaLow, Lane07Low), bit32.bxor(DeltaHigh, Lane07High)
			local Temp2Low, Temp2High = bit32.bxor(DeltaLow, Lane12Low), bit32.bxor(DeltaHigh, Lane12High)
			local Temp3Low, Temp3High = bit32.bxor(DeltaLow, Lane17Low), bit32.bxor(DeltaHigh, Lane17High)
			local Temp4Low, Temp4High = bit32.bxor(DeltaLow, Lane22Low), bit32.bxor(DeltaHigh, Lane22High)

			Lane02Low = (bit32.bor(Temp1Low, 0) - Temp1Low % 1048576) // 1048576 + Temp1High * 4096; Lane02High = (bit32.bor(Temp1High, 0) - Temp1High % 1048576) // 1048576 + Temp1Low * 4096
			Lane07Low = (bit32.bor(Temp3Low, 0) - Temp3Low % 524288) // 524288 + Temp3High * 8192; Lane07High = (bit32.bor(Temp3High, 0) - Temp3High % 524288) // 524288 + Temp3Low * 8192
			Lane12Low = Temp0Low * 2 + (bit32.bor(Temp0High, 0) - Temp0High % 2147483648) // 2147483648; Lane12High = Temp0High * 2 + (bit32.bor(Temp0Low, 0) - Temp0Low % 2147483648) // 2147483648
			Lane17Low = Temp2Low * 1024 + (bit32.bor(Temp2High, 0) - Temp2High % 4194304) // 4194304; Lane17High = Temp2High * 1024 + (bit32.bor(Temp2Low, 0) - Temp2Low % 4194304) // 4194304
			Lane22Low = Temp4Low * 4 + (bit32.bor(Temp4High, 0) - Temp4High % 1073741824) // 1073741824; Lane22High = Temp4High * 4 + (bit32.bor(Temp4Low, 0) - Temp4Low % 1073741824) // 1073741824

			DeltaLow = bit32.bxor(Column2Low, Column4Low * 2 + (bit32.bor(Column4High, 0) - Column4High % 2147483648) // 2147483648); DeltaHigh = bit32.bxor(Column2High, Column4High * 2 + (bit32.bor(Column4Low, 0) - Column4Low % 2147483648) // 2147483648)
			Temp0Low = bit32.bxor(DeltaLow, Lane03Low); Temp0High = bit32.bxor(DeltaHigh, Lane03High)
			Temp1Low = bit32.bxor(DeltaLow, Lane08Low); Temp1High = bit32.bxor(DeltaHigh, Lane08High)
			Temp2Low = bit32.bxor(DeltaLow, Lane13Low); Temp2High = bit32.bxor(DeltaHigh, Lane13High)
			Temp3Low = bit32.bxor(DeltaLow, Lane18Low); Temp3High = bit32.bxor(DeltaHigh, Lane18High)
			Temp4Low = bit32.bxor(DeltaLow, Lane23Low); Temp4High = bit32.bxor(DeltaHigh, Lane23High)

			Lane03Low = (bit32.bor(Temp2Low, 0) - Temp2Low % 2097152) // 2097152 + Temp2High * 2048; Lane03High = (bit32.bor(Temp2High, 0) - Temp2High % 2097152) // 2097152 + Temp2Low * 2048
			Lane08Low = (bit32.bor(Temp4Low, 0) - Temp4Low % 8) // 8 + bit32.bor(Temp4High * 536870912, 0); Lane08High = (bit32.bor(Temp4High, 0) - Temp4High % 8) // 8 + bit32.bor(Temp4Low * 536870912, 0)
			Lane13Low = Temp1Low * 64 + (bit32.bor(Temp1High, 0) - Temp1High % 67108864) // 67108864; Lane13High = Temp1High * 64 + (bit32.bor(Temp1Low, 0) - Temp1Low % 67108864) // 67108864
			Lane18Low = Temp3Low * 32768 + (bit32.bor(Temp3High, 0) - Temp3High % 131072) // 131072; Lane18High = Temp3High * 32768 + (bit32.bor(Temp3Low, 0) - Temp3Low % 131072) // 131072
			Lane23Low = (bit32.bor(Temp0Low, 0) - Temp0Low % 4) // 4 + bit32.bor(Temp0High * 1073741824, 0); Lane23High = (bit32.bor(Temp0High, 0) - Temp0High % 4) // 4 + bit32.bor(Temp0Low * 1073741824, 0)

			DeltaLow = bit32.bxor(Column3Low, Column5Low * 2 + (bit32.bor(Column5High, 0) - Column5High % 2147483648) // 2147483648); DeltaHigh = bit32.bxor(Column3High, Column5High * 2 + (bit32.bor(Column5Low, 0) - Column5Low % 2147483648) // 2147483648)
			Temp0Low = bit32.bxor(DeltaLow, Lane04Low); Temp0High = bit32.bxor(DeltaHigh, Lane04High)
			Temp1Low = bit32.bxor(DeltaLow, Lane09Low); Temp1High = bit32.bxor(DeltaHigh, Lane09High)
			Temp2Low = bit32.bxor(DeltaLow, Lane14Low); Temp2High = bit32.bxor(DeltaHigh, Lane14High)
			Temp3Low = bit32.bxor(DeltaLow, Lane19Low); Temp3High = bit32.bxor(DeltaHigh, Lane19High)
			Temp4Low = bit32.bxor(DeltaLow, Lane24Low); Temp4High = bit32.bxor(DeltaHigh, Lane24High)

			Lane04Low = bit32.bor(Temp3Low * 2097152, 0) + (bit32.bor(Temp3High, 0) - Temp3High % 2048) // 2048; Lane04High = bit32.bor(Temp3High * 2097152, 0) + (bit32.bor(Temp3Low, 0) - Temp3Low % 2048) // 2048
			Lane09Low = bit32.bor(Temp0Low * 268435456, 0) + (bit32.bor(Temp0High, 0) - Temp0High % 16) // 16; Lane09High = bit32.bor(Temp0High * 268435456, 0) + (bit32.bor(Temp0Low, 0) - Temp0Low % 16) // 16
			Lane14Low = bit32.bor(Temp2Low * 33554432, 0) + (bit32.bor(Temp2High, 0) - Temp2High % 128) // 128; Lane14High = bit32.bor(Temp2High * 33554432, 0) + (bit32.bor(Temp2Low, 0) - Temp2Low % 128) // 128
			Lane19Low = (bit32.bor(Temp4Low, 0) - Temp4Low % 256) // 256 + bit32.bor(Temp4High * 16777216, 0); Lane19High = (bit32.bor(Temp4High, 0) - Temp4High % 256) // 256 + bit32.bor(Temp4Low * 16777216, 0)
			Lane24Low = (bit32.bor(Temp1Low, 0) - Temp1Low % 512) // 512 + bit32.bor(Temp1High * 8388608, 0); Lane24High = (bit32.bor(Temp1High, 0) - Temp1High % 512) // 512 + bit32.bor(Temp1Low * 8388608, 0)
			DeltaLow = bit32.bxor(Column4Low, Column1Low * 2 + (bit32.bor(Column1High, 0) - Column1High % 2147483648) // 2147483648); DeltaHigh = bit32.bxor(Column4High, Column1High * 2 + (bit32.bor(Column1Low, 0) - Column1Low % 2147483648) // 2147483648)

			Temp0Low = bit32.bxor(DeltaLow, Lane05Low); Temp0High = bit32.bxor(DeltaHigh, Lane05High)
			Temp1Low = bit32.bxor(DeltaLow, Lane10Low); Temp1High = bit32.bxor(DeltaHigh, Lane10High)
			Temp2Low = bit32.bxor(DeltaLow, Lane15Low); Temp2High = bit32.bxor(DeltaHigh, Lane15High)
			Temp3Low = bit32.bxor(DeltaLow, Lane20Low); Temp3High = bit32.bxor(DeltaHigh, Lane20High)
			Temp4Low = bit32.bxor(DeltaLow, Lane25Low); Temp4High = bit32.bxor(DeltaHigh, Lane25High)

			Lane05Low = Temp4Low * 16384 + (bit32.bor(Temp4High, 0) - Temp4High % 262144) // 262144; Lane05High = Temp4High * 16384 + (bit32.bor(Temp4Low, 0) - Temp4Low % 262144) // 262144
			Lane10Low = bit32.bor(Temp1Low * 1048576, 0) + (bit32.bor(Temp1High, 0) - Temp1High % 4096) // 4096; Lane10High = bit32.bor(Temp1High * 1048576, 0) + (bit32.bor(Temp1Low, 0) - Temp1Low % 4096) // 4096
			Lane15Low = Temp3Low * 256 + (bit32.bor(Temp3High, 0) - Temp3High % 16777216) // 16777216; Lane15High = Temp3High * 256 + (bit32.bor(Temp3Low, 0) - Temp3Low % 16777216) // 16777216
			Lane20Low = bit32.bor(Temp0Low * 134217728, 0) + (bit32.bor(Temp0High, 0) - Temp0High % 32) // 32; Lane20High = bit32.bor(Temp0High * 134217728, 0) + (bit32.bor(Temp0Low, 0) - Temp0Low % 32) // 32
			Lane25Low = (bit32.bor(Temp2Low, 0) - Temp2Low % 33554432) // 33554432 + Temp2High * 128; Lane25High = (bit32.bor(Temp2High, 0) - Temp2High % 33554432) // 33554432 + Temp2Low * 128

			DeltaLow = bit32.bxor(Column5Low, Column2Low * 2 + (bit32.bor(Column2High, 0) - Column2High % 2147483648) // 2147483648); DeltaHigh = bit32.bxor(Column5High, Column2High * 2 + (bit32.bor(Column2Low, 0) - Column2Low % 2147483648) // 2147483648)
			Temp1Low = bit32.bxor(DeltaLow, Lane06Low); Temp1High = bit32.bxor(DeltaHigh, Lane06High)
			Temp2Low = bit32.bxor(DeltaLow, Lane11Low); Temp2High = bit32.bxor(DeltaHigh, Lane11High)
			Temp3Low = bit32.bxor(DeltaLow, Lane16Low); Temp3High = bit32.bxor(DeltaHigh, Lane16High)
			Temp4Low = bit32.bxor(DeltaLow, Lane21Low); Temp4High = bit32.bxor(DeltaHigh, Lane21High)
			Lane06Low = Temp2Low * 8 + (bit32.bor(Temp2High, 0) - Temp2High % 536870912) // 536870912; Lane06High = Temp2High * 8 + (bit32.bor(Temp2Low, 0) - Temp2Low % 536870912) // 536870912
			Lane11Low = Temp4Low * 262144 + (bit32.bor(Temp4High, 0) - Temp4High % 16384) // 16384; Lane11High = Temp4High * 262144 + (bit32.bor(Temp4Low, 0) - Temp4Low % 16384) // 16384
			Lane16Low = (bit32.bor(Temp1Low, 0) - Temp1Low % 268435456) // 268435456 + Temp1High * 16; Lane16High = (bit32.bor(Temp1High, 0) - Temp1High % 268435456) // 268435456 + Temp1Low * 16
			Lane21Low = (bit32.bor(Temp3Low, 0) - Temp3Low % 8388608) // 8388608 + Temp3High * 512; Lane21High = (bit32.bor(Temp3High, 0) - Temp3High % 8388608) // 8388608 + Temp3Low * 512
			Lane01Low = bit32.bxor(DeltaLow, Lane01Low); Lane01High = bit32.bxor(DeltaHigh, Lane01High)

			Lane01Low, Lane02Low, Lane03Low, Lane04Low, Lane05Low =  bit32.bxor(Lane01Low, bit32.band(-1 - Lane02Low, Lane03Low)),  bit32.bxor(Lane02Low, bit32.band(-1 - Lane03Low, Lane04Low)),  bit32.bxor(Lane03Low, bit32.band(-1 - Lane04Low, Lane05Low)),  bit32.bxor(Lane04Low, bit32.band(-1 - Lane05Low, Lane01Low)),  bit32.bxor(Lane05Low, bit32.band(-1 - Lane01Low, Lane02Low))
			Lane01High, Lane02High, Lane03High, Lane04High, Lane05High =  bit32.bxor(Lane01High, bit32.band(-1 - Lane02High, Lane03High)),  bit32.bxor(Lane02High, bit32.band(-1 - Lane03High, Lane04High)),  bit32.bxor(Lane03High, bit32.band(-1 - Lane04High, Lane05High)),  bit32.bxor(Lane04High, bit32.band(-1 - Lane05High, Lane01High)),  bit32.bxor(Lane05High, bit32.band(-1 - Lane01High, Lane02High))
			Lane06Low, Lane07Low, Lane08Low, Lane09Low, Lane10Low =  bit32.bxor(Lane09Low, bit32.band(-1 - Lane10Low, Lane06Low)),  bit32.bxor(Lane10Low, bit32.band(-1 - Lane06Low, Lane07Low)),  bit32.bxor(Lane06Low, bit32.band(-1 - Lane07Low, Lane08Low)),  bit32.bxor(Lane07Low, bit32.band(-1 - Lane08Low, Lane09Low)),  bit32.bxor(Lane08Low, bit32.band(-1 - Lane09Low, Lane10Low))
			Lane06High, Lane07High, Lane08High, Lane09High, Lane10High =  bit32.bxor(Lane09High, bit32.band(-1 - Lane10High, Lane06High)),  bit32.bxor(Lane10High, bit32.band(-1 - Lane06High, Lane07High)),  bit32.bxor(Lane06High, bit32.band(-1 - Lane07High, Lane08High)),  bit32.bxor(Lane07High, bit32.band(-1 - Lane08High, Lane09High)),  bit32.bxor(Lane08High, bit32.band(-1 - Lane09High, Lane10High))
			Lane11Low, Lane12Low, Lane13Low, Lane14Low, Lane15Low =  bit32.bxor(Lane12Low, bit32.band(-1 - Lane13Low, Lane14Low)),  bit32.bxor(Lane13Low, bit32.band(-1 - Lane14Low, Lane15Low)),  bit32.bxor(Lane14Low, bit32.band(-1 - Lane15Low, Lane11Low)),  bit32.bxor(Lane15Low, bit32.band(-1 - Lane11Low, Lane12Low)),  bit32.bxor(Lane11Low, bit32.band(-1 - Lane12Low, Lane13Low))
			Lane11High, Lane12High, Lane13High, Lane14High, Lane15High =  bit32.bxor(Lane12High, bit32.band(-1 - Lane13High, Lane14High)),  bit32.bxor(Lane13High, bit32.band(-1 - Lane14High, Lane15High)),  bit32.bxor(Lane14High, bit32.band(-1 - Lane15High, Lane11High)),  bit32.bxor(Lane15High, bit32.band(-1 - Lane11High, Lane12High)),  bit32.bxor(Lane11High, bit32.band(-1 - Lane12High, Lane13High))
			Lane16Low, Lane17Low, Lane18Low, Lane19Low, Lane20Low =  bit32.bxor(Lane20Low, bit32.band(-1 - Lane16Low, Lane17Low)),  bit32.bxor(Lane16Low, bit32.band(-1 - Lane17Low, Lane18Low)),  bit32.bxor(Lane17Low, bit32.band(-1 - Lane18Low, Lane19Low)),  bit32.bxor(Lane18Low, bit32.band(-1 - Lane19Low, Lane20Low)),  bit32.bxor(Lane19Low, bit32.band(-1 - Lane20Low, Lane16Low))
			Lane16High, Lane17High, Lane18High, Lane19High, Lane20High =  bit32.bxor(Lane20High, bit32.band(-1 - Lane16High, Lane17High)),  bit32.bxor(Lane16High, bit32.band(-1 - Lane17High, Lane18High)),  bit32.bxor(Lane17High, bit32.band(-1 - Lane18High, Lane19High)),  bit32.bxor(Lane18High, bit32.band(-1 - Lane19High, Lane20High)),  bit32.bxor(Lane19High, bit32.band(-1 - Lane20High, Lane16High))
			Lane21Low, Lane22Low, Lane23Low, Lane24Low, Lane25Low =  bit32.bxor(Lane23Low, bit32.band(-1 - Lane24Low, Lane25Low)),  bit32.bxor(Lane24Low, bit32.band(-1 - Lane25Low, Lane21Low)),  bit32.bxor(Lane25Low, bit32.band(-1 - Lane21Low, Lane22Low)),  bit32.bxor(Lane21Low, bit32.band(-1 - Lane22Low, Lane23Low)),  bit32.bxor(Lane22Low, bit32.band(-1 - Lane23Low, Lane24Low))
			Lane21High, Lane22High, Lane23High, Lane24High, Lane25High =  bit32.bxor(Lane23High, bit32.band(-1 - Lane24High, Lane25High)),  bit32.bxor(Lane24High, bit32.band(-1 - Lane25High, Lane21High)),  bit32.bxor(Lane25High, bit32.band(-1 - Lane21High, Lane22High)),  bit32.bxor(Lane21High, bit32.band(-1 - Lane22High, Lane23High)),  bit32.bxor(Lane22High, bit32.band(-1 - Lane23High, Lane24High))

			Lane01Low =  bit32.bxor(Lane01Low, buffer.readu32(RCLow, RoundIndex))
			Lane01High = Lane01High + buffer.readu32(RCHigh, RoundIndex)
		end

		buffer.writeu32(LanesLow, 0, Lane01Low); buffer.writeu32(LanesHigh, 0, Lane01High)
		buffer.writeu32(LanesLow, 4, Lane02Low); buffer.writeu32(LanesHigh, 4, Lane02High)
		buffer.writeu32(LanesLow, 8, Lane03Low); buffer.writeu32(LanesHigh, 8, Lane03High)
		buffer.writeu32(LanesLow, 12, Lane04Low); buffer.writeu32(LanesHigh, 12, Lane04High)
		buffer.writeu32(LanesLow, 16, Lane05Low); buffer.writeu32(LanesHigh, 16, Lane05High)
		buffer.writeu32(LanesLow, 20, Lane06Low); buffer.writeu32(LanesHigh, 20, Lane06High)
		buffer.writeu32(LanesLow, 24, Lane07Low); buffer.writeu32(LanesHigh, 24, Lane07High)
		buffer.writeu32(LanesLow, 28, Lane08Low); buffer.writeu32(LanesHigh, 28, Lane08High)
		buffer.writeu32(LanesLow, 32, Lane09Low); buffer.writeu32(LanesHigh, 32, Lane09High)
		buffer.writeu32(LanesLow, 36, Lane10Low); buffer.writeu32(LanesHigh, 36, Lane10High)
		buffer.writeu32(LanesLow, 40, Lane11Low); buffer.writeu32(LanesHigh, 40, Lane11High)
		buffer.writeu32(LanesLow, 44, Lane12Low); buffer.writeu32(LanesHigh, 44, Lane12High)
		buffer.writeu32(LanesLow, 48, Lane13Low); buffer.writeu32(LanesHigh, 48, Lane13High)
		buffer.writeu32(LanesLow, 52, Lane14Low); buffer.writeu32(LanesHigh, 52, Lane14High)
		buffer.writeu32(LanesLow, 56, Lane15Low); buffer.writeu32(LanesHigh, 56, Lane15High)
		buffer.writeu32(LanesLow, 60, Lane16Low); buffer.writeu32(LanesHigh, 60, Lane16High)
		buffer.writeu32(LanesLow, 64, Lane17Low); buffer.writeu32(LanesHigh, 64, Lane17High)
		buffer.writeu32(LanesLow, 68, Lane18Low); buffer.writeu32(LanesHigh, 68, Lane18High)
		buffer.writeu32(LanesLow, 72, Lane19Low); buffer.writeu32(LanesHigh, 72, Lane19High)
		buffer.writeu32(LanesLow, 76, Lane20Low); buffer.writeu32(LanesHigh, 76, Lane20High)
		buffer.writeu32(LanesLow, 80, Lane21Low); buffer.writeu32(LanesHigh, 80, Lane21High)
		buffer.writeu32(LanesLow, 84, Lane22Low); buffer.writeu32(LanesHigh, 84, Lane22High)
		buffer.writeu32(LanesLow, 88, Lane23Low); buffer.writeu32(LanesHigh, 88, Lane23High)
		buffer.writeu32(LanesLow, 92, Lane24Low); buffer.writeu32(LanesHigh, 92, Lane24High)
		buffer.writeu32(LanesLow, 96, Lane25Low); buffer.writeu32(LanesHigh, 96, Lane25High)
	end
end

local function ProcessSponge(Message: buffer, CapacityBits: number, OutputBytes: number, DomainSeparator: number): string
	local RateBytes = (1600 - CapacityBits) // 8
	local LanesLow = buffer.create(100)
	local LanesHigh = buffer.create(100)

	buffer.fill(LanesLow, 0, 0, 100)
	buffer.fill(LanesHigh, 0, 0, 100)

	local MessageLength: number = buffer.len(Message)
	local PaddedLength: number = MessageLength + 1

	local Remainder = PaddedLength % RateBytes
	if Remainder ~= 0 then
		PaddedLength += (RateBytes - Remainder)
	end

	local PaddedMessage: buffer = buffer.create(PaddedLength)

	if MessageLength > 0 then
		buffer.copy(PaddedMessage, 0, Message, 0, MessageLength)
	end

	if PaddedLength - MessageLength == 1 then
		buffer.writeu8(PaddedMessage, MessageLength, bit32.bor(DomainSeparator, 0x80))
	else
		buffer.writeu8(PaddedMessage, MessageLength, DomainSeparator)
		if PaddedLength - MessageLength > 2 then
			buffer.fill(PaddedMessage, MessageLength + 1, 0, PaddedLength - MessageLength - 2)
		end
		buffer.writeu8(PaddedMessage, PaddedLength - 1, 0x80)
	end

	Keccak(LanesLow, LanesHigh, PaddedMessage, 0, PaddedLength, RateBytes)

	local Output = if OutputBytes <= 64 then OUTPUT_BUFFER else buffer.create(OutputBytes)
	local OutputOffset: number = 0

	while OutputOffset < OutputBytes do
		local BytesThisRound: number = math.min(RateBytes, OutputBytes - OutputOffset)

		for ByteIndex = 0, BytesThisRound - 1 do
			local AbsoluteIndex: number = OutputOffset + ByteIndex
			if AbsoluteIndex < OutputBytes then
				local Lane: number = ByteIndex // 8
				local ByteInLane: number = ByteIndex % 8
				local LaneOffset: number = Lane * 4

				local Value: number
				if ByteInLane < 4 then
					Value = bit32.extract(buffer.readu32(LanesLow, LaneOffset), ByteInLane * 8, 8)
				else
					Value = bit32.extract(buffer.readu32(LanesHigh, LaneOffset), (ByteInLane - 4) * 8, 8)
				end
				buffer.writeu8(Output, AbsoluteIndex, Value)
			end
		end

		OutputOffset += BytesThisRound

		if OutputOffset < OutputBytes then
			local ZeroBuffer = buffer.create(RateBytes)
			Keccak(LanesLow, LanesHigh, ZeroBuffer, 0, RateBytes, RateBytes)
		end
	end

	local Hex = buffer.create(OutputBytes * 2)
	for Index = 0, OutputBytes - 1 do
		buffer.writestring(Hex, Index * 2, string.format("%02x", buffer.readu8(Output, Index)))
	end

	return buffer.tostring(Hex)
end

local SHA3 = {}

function SHA3.SHA3_224(Message: buffer): string
	return ProcessSponge(Message, 448, 28, 0x06)
end

function SHA3.SHA3_256(Message: buffer): string
	return ProcessSponge(Message, 512, 32, 0x06)
end

function SHA3.SHA3_384(Message: buffer): string
	return ProcessSponge(Message, 768, 48, 0x06)
end

function SHA3.SHA3_512(Message: buffer): string
	return ProcessSponge(Message, 1024, 64, 0x06)
end

function SHA3.SHAKE128(Message: buffer, OutputBytes: number): string
	return ProcessSponge(Message, 256, OutputBytes, 0x1F)
end

function SHA3.SHAKE256(Message: buffer, OutputBytes: number): string
	return ProcessSponge(Message, 512, OutputBytes, 0x1F)
end

return SHA3