# frozen_string_literal: true

require "nomad"

class NomadClient
  def initialize
    
  end

  def logs(task, allocation)
    
  end
end


module Nomad
  class Client
    def request(verb, path, data = {}, headers = {})
      uri = URI.parse(path)
      if uri.absolute?
        new_path, uri.path, uri.fragment = uri.path, "", nil
        client = self.class.new(options.merge(
          address: uri.to_s,
        ))
        return client.request(verb, new_path, data, headers)
      end

      # Build the URI and request object from the given information
      path = build_uri(verb, path, data)
      req = class_for_request(verb).new(path)

      # Get a list of headers
      headers = Nomad::Client::DEFAULT_HEADERS.merge(headers)
      headers = headers.merge({ "X-Nomad-Token" => ENV["NOMAD_TOKEN"] })

      # Add headers
      headers.each do |key, value|
        req.add_field(key, value)
      end

      # Setup PATCH/POST/PUT
      if [:patch, :post, :put].include?(verb)
        if data.respond_to?(:read)
          req.content_length = data.size
          req.body_stream = data
        elsif data.is_a?(Hash)
          req.form_data = data
        else
          req.body = data
        end
      end

      begin
        response = connection.request(req)
        case response
        when Net::HTTPRedirection
          # On a redirect of a GET or HEAD request, the URL already contains
          # the data as query string parameters.
          if [:head, :get].include?(verb)
            data = {}
          end
          request(verb, response[LOCATION_HEADER], data, headers)
        when Net::HTTPSuccess
          success(response)
        else
          error(response)
        end
      rescue *RESCUED_EXCEPTIONS => e
        raise Nomad::HTTPConnectionError.new(address, e)
      end
    end
  end
end
