require 'fileutils'
require 'listen'

module DASH
	class GarbageCollector

		include DASH::Dispatch

		# seconds of history to keep 
		attr_accessor :history, :chunk_length

		def initialize path, prefix, extension, history, chunk_length

			raise "Bad path" if !path.is_a?(String) or path.empty?
			raise "Bad extension" if !extension.is_a?(String) or extension.empty?
			raise "History must be greater than 2*chunk_length (at a minimum, but that's crazy too)" if history < chunk_length * 2

			@history = history
			@chunk_length = chunk_length

			@path = path; @prefix = prefix; @extension = extension
			@listener = Listen.to(path, &method(:on_change))
			@listener.only (@pattern = Regexp.new(Regexp.escape("#{prefix}") + "([0-9]+)" + "#{extension}$"))
			p @pattern
			@listener.start

		end

		# Return an array of files ready to be garbage collected
		def collect current_chunk

			files = Dir.glob(a = @path + @prefix + "*" + @extension)
			deletable = []
			files.each do | f |

				matches = f.match(@pattern)
				next if matches.nil?
				next if matches[1].to_i > last_acceptable(current_chunk)
				deletable << f 

			end
			deletable

		end

		# Remove those pesky old files!
		def collect! current_chunk
			DASH.logger.debug("Running GC")
			FileUtils.rm collect(current_chunk)
		end

		private
		def on_change modified, added, removed

			new_chunks = []
			(added + modified).uniq.each do | a | 

				matches = a.match(@pattern)
				next if matches.nil?

				new_chunks << matches[1].to_i

			end

			return if new_chunks.length == 0

			latest_chunk = new_chunks.sort.last
			time = Time.now - @chunk_length

			dispatch DASH::Event::NewChunk.new, latest_chunk, time, self

		end

		# history = 3600
		# chunk_length = 10
		# current_chunk = 1234
		# expected = current_chunk - (history / chunk_length)
		def last_acceptable current_chunk
			current_chunk - (@history / @chunk_length)
		end

	end
end