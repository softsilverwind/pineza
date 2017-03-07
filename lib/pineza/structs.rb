require_relative 'modules'

module Pineza::Structs
	class ::Struct
		def to_json(*args)
			self.to_h.to_json(*args)
		end
	end

	Point = Struct.new(:lat, :lon, :info)
	Line = Struct.new(:start, :finish, :color)
end
