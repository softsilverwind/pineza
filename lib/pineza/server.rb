require 'webrick'
require 'json'

require_relative 'modules'

class Pineza::Servlet < WEBrick::HTTPServlet::AbstractServlet
	attr_reader :points, :lines

	Datadir = File.join(Gem.loaded_specs['pineza'].full_gem_path, 'data') || 'data'

	def initialize(server, worker)
		@worker = worker
	end

	def do_GET (request, response)
		case request.path
		when '/'
			response.status = 200
			response.content_type = 'text/html'
			response.body = ERB.new(File.read(File.join(Datadir, 'leaflet.erb')), 0, '<>').result
		when '/data'
			response.status = 200
			response.content_type = 'application/json'
			response.body = JSON.generate(@worker.current_dataset)
		else
			response.status = 404
			response.content_type = 'text/html'
			response.body = 'method not found'
		end
	end

	def do_POST (request, response)
		case request.path
		when '/keypress'
			response.content_type = 'text/html'
			response.status = 200
			response.body = "OK"

			char = JSON.parse(request.body)['character']
			callback = @worker.keypress_callback(char)
			if callback
				case callback.arity
				when 0
					callback.call()
				when 1
					callback.call(char)
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end
		when '/click'
			response.content_type = 'text/html'
			response.status = 200
			response.body = "OK"

			lat, lon = JSON.parse(request.body)['latlng']
			callback = @worker.click_callback()
			if callback
				case callback.arity
				when 0
					callback.call()
				when 2
					callback.call(lat, lon)
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end
		else
			response.status = 404
			response.content_type = 'text/html'
			response.body = 'method not found'
		end
	end
end
