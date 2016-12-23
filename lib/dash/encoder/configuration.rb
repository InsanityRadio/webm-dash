module DASH
	class Encoder
		class Configuration

			attr_reader :input, :path, :prefix, :history, :chunk_length
			attr_accessor :source, :encoder, :codec, :bitrate

			def initialize input, path, prefix, history, chunk_length
				@input = input
				@path = path
				@prefix = prefix
				@history = history
				@chunk_length = chunk_length
			end

		end
	end
end