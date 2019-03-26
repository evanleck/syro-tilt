# frozen_string_literal: true
require_relative '../tilt'

class Syro # :nodoc:
  module Tilt
    # Add template and path caching to Syro::Tilt.
    module Cache
      # A very thin wrapper around Hash, with a Mutex.
      class MemoryStore
        def initialize
          @cache = {}
          @mutex = Mutex.new
        end

        def fetch(*key)
          @mutex.synchronize do
            @cache.fetch(key) do
              @cache[key] = yield
            end
          end
        end
      end

      @template_cache = MemoryStore.new
      @template_path_cache = MemoryStore.new

      # @return [MemoryStore]
      def self.template_cache
        @template_cache
      end

      # @return [MemoryStore]
      def self.template_path_cache
        @template_path_cache
      end

      # Cache calls to Syro::Tilt#template.
      def template(path)
        Cache.template_cache.fetch(path) do
          super(path)
        end
      end

      # Cache calls to Syro::Tilt#template_path.
      def template_path(path, from, accept)
        Cache.template_path_cache.fetch(path, from, accept) do
          super(path, from, accept)
        end
      end
    end
  end

  Tilt.prepend(Tilt::Cache)
end
