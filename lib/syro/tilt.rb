# frozen_string_literal: true
require 'syro'
require 'tilt'

class Syro # :nodoc:
  # Render Tilt templates in Syro routes.
  module Tilt
    DEFAULT_MIME_TYPE = 'text/plain'
    DOT = '.'
    EMPTY = ''
    HTTP_ACCEPT = 'HTTP_ACCEPT'
    MIME_TYPE_ANY = '*/*'

    ACCEPT_CAPTURE_QUALITY = /\Aq=([\d.]+)/.freeze
    ACCEPT_SPLIT_MULTIPLES = /\s*,\s*/.freeze
    ACCEPT_SPLIT_PARTS = /\s*;\s*/.freeze

    # A Tilt template for the file path passed in.
    #
    # @return [Tilt::Template]
    def template(path)
      ::Tilt.new(path, template_options(::Tilt.template_for(path)))
    end

    # Options passed to Tilt.new.
    #
    # @param templ [Class]
    #   The class of the template engine being used e.g. "Tilt::ErubiTemplate".
    #
    # @return [Hash]
    def template_options(_templ = nil)
      {}
    end

    # The default directory to look for templates within.
    #
    # @return [String]
    def templates_directory
      'views'
    end

    # Find a template's file path based on a "fuzzy" name like "posts/show". The
    # HTTP Accept header will be checked and the first template found that
    # matches the MIME type of the Accept header will be used, otherwise the
    # first matching template file will be used.
    #
    # @param path [String]
    #   A "fuzzy" file path like "posts/show".
    # @param from [String]
    #   The directory to look for templates within.
    #
    # @return [String]
    #   The path to the template file.
    def template_path(path, from = nil)
      from ||= templates_directory
      path = File.join(from, path)

      accepts = env.fetch(HTTP_ACCEPT) { EMPTY }.to_s.then do |header|
        # Taken from Rack::Request#parse_http_accept_header (which is a private
        # method).
        header.split(ACCEPT_SPLIT_MULTIPLES).map do |part|
          attribute, parameters = part.split(ACCEPT_SPLIT_PARTS, 2)
          quality = 1.0

          if parameters && ACCEPT_CAPTURE_QUALITY.match?(parameters)
            quality = ACCEPT_CAPTURE_QUALITY.match(parameters)[1].to_f
          end

          [attribute, quality]
        end
      end

      # Reject "*/*" because it will always match the first thing it is compared
      # to, regardless of wether there's a better match coming up.
      accepts.reject! { |acc, _q| acc == MIME_TYPE_ANY }

      # Find all potential templates e.g. ones with the same name but different
      # template engines or MIME types.
      potentials = Dir.glob(File.join(from, '**', '*')).filter do |potential|
        potential.start_with?(path)
      end.sort

      # Select the best potential template match based on MIME type and HTTP
      # Accept header.
      potentials.find do |potential|
        content_type = template_mime_type(potential)

        accepts.any? do |acc, _quality|
          Rack::Mime.match?(content_type, acc)
        end
      end || potentials.first
    end

    # Get the MIME type of a template file. The MIME type is looked up from
    # Rack's MIME type list.
    #
    # @return [String]
    def template_mime_type(path)
      File.basename(path).split(DOT).reverse.map do |ext|
        Rack::Mime::MIME_TYPES[".#{ ext.downcase }"]
      end.compact.first || DEFAULT_MIME_TYPE
    end

    # Generate a string by rendering the Tilt template in the context of `self`
    # with the locals that were passed in.
    #
    # @example
    #   partial('posts/show') # => "OMG look at this page!"
    #
    # @param path [String]
    #   The path to the view template you'd like to render.
    # @param locals [Hash]
    #   The local variables to pass to the template.
    # @option locals [String] :from
    #   The directory to look for templates within.
    #
    # @return [String]
    def partial(path, locals = {})
      template(template_path(path, locals.delete(:from))).render(self, locals) { yield if block_given? }
    end

    # Set or get the current layout. A layout is just another template to wrap
    # other templates in. If set, it'll be used by #render.
    #
    # @param path [String]
    #   A path to a template file.
    #
    # @return [String, nil]
    def layout(templ = nil)
      inbox[:tilt_layout] = templ if templ
      inbox[:tilt_layout]
    end

    # Render a template to Syro's #res object and write the appropriate MIME
    # type based on the rendered template.
    #
    # @param path [String]
    #   The path to a view file.
    # @param locals [Hash]
    #   Local variables that should be accessible to the view.
    # @option locals [String] :from
    #   The directory to look for templates within.
    def render(path, locals = {})
      content = partial(path, locals.dup) { yield if block_given? }
      content = partial(layout, locals.dup) { content } if layout

      res.headers[Rack::CONTENT_TYPE] = template_mime_type(template_path(path, locals[:from]))
      res.write content
    end

    # Capture content from a block for use later. Note that capturing the block
    # is not implemented here due to the differences in varying template
    # languages. Erubi::CaptureEndEngine and Hamlit::Block::Engine work well
    # with this method.
    #
    # @param key [Symbol]
    #   The content key name.
    #
    # @return [String]
    #   An empty string if content is provided, otherwise the joined contents of
    #   the provided key.
    def content_for(key)
      inbox[:tilt_content_for] ||= {}
      inbox[:tilt_content_for][key] ||= []

      if block_given?
        inbox[:tilt_content_for][key].push yield

        EMPTY # Returned to prevent the result of #push from displaying.
      else
        inbox[:tilt_content_for].delete(key).join
      end
    end

    # Determine if there's content to display.
    #
    # @param key [Symbol]
    #   The key to check for captured content for.
    #
    # @return [Boolean]
    #   Have we captured any content for this key?
    def content_for?(key)
      inbox[:tilt_content_for] ||= {}
      inbox[:tilt_content_for][key] ||= []

      !inbox[:tilt_content_for][key].empty?
    end
  end

  Deck.include Tilt
end
