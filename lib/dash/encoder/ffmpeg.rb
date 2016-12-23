require 'open3'

module DASH
	class Encoder
		class FFmpeg

			def initialize input, chunk_length, bitrate, codec
				@input = input
				@chunk_length = chunk_length
				@bitrate = bitrate
				@codec = codec
			end

			def start! initial_chunk, chunk_path, header_path

=begin
	
ffmpeg \
  -i http://127.0.0.1:8000/insanity320.mp3 \
  -map 0 \
  -c:a libvorbis \
    -b:a 256k -ar 48000 \
  -f webm_chunk \
    -audio_chunk_duration 10000 \
    -header /srv/dash/insanity_256.hdr \
    -chunk_start_index 1 \
  /srv/dash/insanity_256_%d.chk
	
=end

				p = [
					"ffmpeg",
					"-i", @input,
					"-map", "0",
					"-c:a", @codec,
					"-b:a", @bitrate,
					"-f", "webm_chunk",
					"-audio_chunk_duration", @chunk_length.to_s,
					"-header", header_path,
					"-chunk_start_index", initial_chunk.to_s,
					chunk_path]

				p p

				stdout, stderr, status = Open3.capture3(*p)

				DASH.logger.error("FFmpeg exited! Exit code: #{status}")
				status == 0

			end

		end
	end
end