require 'yaml'

module DASH
	class Server

		def initialize file
			@config = YAML::load(file)
			$start = Time.now

			DASH.logger.level = Object.get(@config["logging"]) rescue Logger::INFO

			DASH::Controller.new @config
		end

	end
end