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
			@worker.get_params = request.query
			response.status = 200
			response.content_type = 'text/html'
			response.body = File.read(File.join(Datadir, 'index.html'))
		when '/data'
			response.status = 200
			response.content_type = 'application/json'
			response.body = @worker.dataset.to_json
		when '/metadata'
			response.status = 200
			response.content_type = 'application/json'
			response.body = @worker.metadata.to_json
		else
			file = File.join(Datadir, request.path[1..-1])
			ext = file.split('.')[-1]

			if File.exists?(file)
				response.status = 200
				case ext
				when 'html'
					response.content_type = 'text/html'
				when 'js'
					response.content_type = 'application/javascript'
				when 'ico'
					response.content_type = 'image/x-icon'
				end
				response.body = File.read(file)
			else
				response.status = 404
				response.content_type = 'text/html'
				response.body = 'Page not found'
			end
		end
	end

	def do_POST (request, response)
		case request.path
		when '/keypress'
			response.status = 200
			response.content_type = 'text/html'

			char = JSON.parse(request.body)['character']
			callback = @worker.keypress_callback(char)
			if callback
				case callback.arity
				when 0
					ret = callback.call()
				when 1
					ret = callback.call(char)
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end

			response.body =
				if ret.class == Hash
					puts ret[:msg]
					ret.to_json
				else
					{ msg: '' }.to_json
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
					ret = callback.call()
				when 2
					ret = callback.call(lat, lon)
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end

			response.body =
				if ret.class == Hash then
					puts ret[:msg]
					ret.to_json
				else
					{ msg: '' }.to_json
				end
		when '/marker_click'
			response.content_type = 'text/html'
			response.status = 200
			response.body = "OK"

			id = JSON.parse(request.body)['id']
			callback = @worker.marker_click_callback()
			if callback
				case callback.arity
				when 0
					ret = callback.call()
				when 1
					ret = callback.call(id)
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end

			response.body =
				if ret.class == Hash then
					puts ret[:msg]
					ret.to_json
				else
					{ msg: '' }.to_json
				end
		else
			response.status = 404
			response.content_type = 'text/html'
			response.body = 'method not found'
		end
	end

	def do_PUT (request, response)
		case request.path
		when '/data'
			response.status = 200
			response.content_type = 'text/html'
			response.body = { }

			callback = @worker.edit_callback()
			if callback
				case callback.arity
				when 0
					ret = callback.call()
				when 1
					ret = callback.call(JSON.parse(request.body))
				else
					response.status = 500
					response.body = "Invalid callback"
				end
			end

			response.body =
				if ret.class == Hash then
					puts ret[:msg]
					ret.to_json
				else
					{ msg: '' }.to_json
				end
		else
			response.status = 404
			response.content_type = 'text/html'
			response.body = 'method not found'
		end
	end
end
