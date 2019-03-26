# frozen_string_literal: true
require_relative '../lib/syro/tilt'
require 'minitest/autorun'
require 'syro'

describe Syro::Tilt do
  include Syro::Tilt

  let(:inbox) do
    {}
  end

  let(:templates_directory) do
    'test/views'
  end

  let(:env) do
    {}
  end

  describe '#template_path' do
    it 'returns the path for an existing file' do
      assert_equal 'test/views/plain.txt.erb', template_path('plain.txt.erb')
    end

    it 'finds the first match for an ambiguous file' do
      assert_equal 'test/views/plain.anope.erb', template_path('plain')
    end

    it "returns nil for files that don't exist" do
      assert_nil template_path('nah.txt')
    end
  end

  describe '#layout' do
    it 'is nil by default' do
      assert_nil layout
    end

    it 'can be set' do
      layout('something')

      assert_equal 'something', layout
    end
  end

  describe '#partial' do
    it 'returns the contents of a template' do
      assert_equal "First plain text.\n", partial('plain')
    end

    it 'accepts local variables' do
      assert_equal "Locals rule!\n", partial('locals', what: 'rule')
    end

    it 'accepts a block' do
      assert_equal "Layout!\n\nNot so plain!\n\n", partial('layout') { partial('notsoplain') }
    end

    describe 'template disambiguation' do
      it 'picks the first one found without clear accepts' do
        assert_equal "This is the first.\n", partial('typed')
      end

      describe 'disambiguation by HTTP Accept' do
        let(:env) do
          { 'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' }
        end

        it "checks the environment's 'Accept' header when present" do
          assert_equal "This is HTML.\n", partial('typed')
        end
      end

      describe 'disambiguation by HTTP Accept' do
        let(:env) do
          { 'HTTP_ACCEPT' => 'application/json' }
        end

        it "checks the environment's 'Accept' header when present" do
          assert_equal %({ "thisis": "json" }\n), partial('typed')
        end
      end
    end
  end

  describe '#render' do
    let(:res) do
      Syro::Response.new
    end

    it 'writes plain text to the response' do
      render('plain')

      assert_equal 'text/plain', res.headers['Content-Type']
      assert_equal ["First plain text.\n"], res.body
    end

    it 'writes html text to the response' do
      render('notsoplain')

      assert_equal 'text/html', res.headers['Content-Type']
      assert_equal ["Not so plain!\n"], res.body
    end

    it 'accepts local variables' do
      render('locals', what: 'rule')

      assert_equal ["Locals rule!\n"], res.body
    end

    it 'uses the layout when present' do
      layout('layout')
      render('notsoplain')

      assert_equal ["Layout!\n\nNot so plain!\n\n"], res.body
    end
  end

  describe '#content_for' do
    it 'captures content from a block' do
      content_for(:capture) do
        'This is a capture.'
      end

      assert_equal 'This is a capture.', content_for(:capture)
    end

    it 'deletes content once output' do
      content_for(:capture) do
        'This is a capture.'
      end

      assert_equal 'This is a capture.', content_for(:capture)
      assert_equal '', content_for(:capture)
    end
  end

  describe '#content_for?' do
    it 'reports captured content' do
      content_for(:capture) do
        'This is a capture.'
      end

      assert content_for?(:capture)
      refute content_for?(:notthere)
    end
  end

  describe '#template' do
    it 'returns a Tilt template' do
      assert_instance_of Tilt::ErubiTemplate, template('test/views/typed.html.erb')
    end

    it "raises an error on missing files (Tilt's default behavior)" do
      assert_raises(Errno::ENOENT) do
        template('test/views/notthere.txt.erb')
      end
    end
  end

  describe 'Syro::Tilt::Cache' do
    require_relative '../lib/syro/tilt/cache'

    prepend Syro::Tilt::Cache

    it 'caches templates' do
      initial = template('test/views/typed.html.erb')

      assert_equal initial, Syro::Tilt::Cache.template_cache.fetch('test/views/typed.html.erb')
    end

    it 'caches template paths' do
      initial = template_path('typed.html', 'test/views', 'html')

      assert_equal initial, Syro::Tilt::Cache.template_path_cache.fetch('typed.html', 'test/views', 'html')
    end
  end
end
