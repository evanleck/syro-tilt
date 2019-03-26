# Syro::Tilt

Render [Tilt][tilt] templates in [Syro][syro] routes.


## Usage

An example Syro app using Syro::Tilt would look like this:

```erb
<%# 'html.html.erb' %>
<% greeting = 'Hey there!' %>

<p>
  <%= greeting %>
</p>
```

```ruby
require 'syro'
require 'syro/tilt'

app = Syro.new do
  get do
    render 'home'
  end
end
```

Calling `render` will look for a template file (e.g. "views/home.html.erb"),
render it in the context of the route, write the content to Syro's response, and
set the `Content-Type` header based on the file extension (i.e. the ".html"
means that it's a `text/html` response).


## API

`partial`: render a template from Tilt into a string, optionally passing in
local variables and yielding to a block.

`render`: render a Tilt template to a string (using `partial`), write the
contents to Syro's response, and set the content type.

`layout`: set (or get) a layout file to be used to wrap calls to `render`.

`templates_directory`: the default directory to look for template files in.
Overwriting this method is the recommended way to configure your template
location. For example:

```ruby
def templates_directory
  'app/views'
end
```

`template_options`: a hash of options passed to `Tilt.new`. The class of the
template being instantiated is passed so you can customize the options for each
template engine. Overwriting this method is the recommended way to configure
template options per engine. For example:

```ruby
def template_options(templ)
  if templ == Hamlit::Block::Engine
    { escape_html: true }
  elsif templ == Tilt::ErubiTemplate
    { engine_class: Erubi::CaptureEndEngine, escape: true, escape_capture: false, freeze: true, yield_returns_buffer: true }
  else
    {}
  end
end
```

`template`: create a new `Tilt` instance from a path to a template.

`content_for`: capture content for use later.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'syro-tilt', require: 'syro/tilt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install syro-tilt


## License

The gem is available as open source under the terms of the [MIT License][mit].


[mit]: https://opensource.org/licenses/MIT
[syro]: https://github.com/soveran/syro
[tilt]: https://github.com/rtomayko/tilt
