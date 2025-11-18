# Butterscotch

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/butterscotch`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

Butterscotch provides a tiny Rack-compatible router with a simple, expressive API.

Example `main.rb`:

```ruby
require 'bundler/setup'
require 'butterscotch'

# Either works
# app = Butterscotch::App.new
app = Butterscotch.new

app.get "/" do |context|
  context.text "hello"
end

app.get "/hello/:name" do |context|
  context.text "Hello, #{context.params["name"]}!"
end

app.group "/api" do |group|
  group.get "/ping" do |context|
    context.json ok: true, ip: context.ip
  end
end

app.run
```

To run the same app with `rackup`, create a minimal `config.ru`:

```ruby
require_relative 'main'
run Butterscotch::CLI.app
```

Run with butterscotch CLI (Bundler ensures rackup/webrick are available):

```bash
# Default: loads ./main.rb automatically
bundle exec butterscotch -p 3000 -o 127.0.0.1

# Using an explicit config.ru
bundle exec butterscotch -c config.ru -p 3000 -o 127.0.0.1

# Or pointing to another Ruby file that calls app.run
bundle exec butterscotch -f path/to/app.rb
```

Notes:
- If you prefer rackup, `rackup` also works with the same config.ru.
- Response headers follow Rack 3 rules and are lower-case (e.g. `content-type`).

### Routing
- Methods: `get`, `post`, `put`, `patch`, `delete`, `options`, `head`, `trace`, `any`
- Params: `:id` like `/users/:id`, splat `*` like `/files/*`
- Groups: `app.group "/api" { |group| group.get "/ping" { ... } }` (nestable)
- HEAD: Uses matching `GET` route, returns empty body and sets `Content-Length` when possible.

### Context API
- `req`: Rack request object (`Rack::Request`)
- `params`: Path parameters hash
- `ip`: Client IP
- `status(code)`: Set response status (default 200)
- `header(key, value)`: Set a response header; `header(key)` to get
- `headers(hash)`: Merge multiple headers; returns current headers
- `text(body, status: nil, headers: {})`: Return plain text
- `html(body, status: nil, headers: {})`: Return HTML
- `json(obj = nil, status: nil, headers: {}, **kw)`: Return JSON
- `redirect(location, status: 302, headers: {})`: Redirect helper
- `halt(code = nil, body = nil, headers: {})`: Immediately stop and return given response
- `request_header(name)`: Read request header (e.g. `HTTP_X_REQUEST_ID`)

### Handlers
Besides blocks, you can pass handler objects or classes that implement `#call`.

```ruby
class HelloHandler
  def call(context)
    context.text "hi"
  end
end

class OkHandler
  def call
    "ok"
  end
end

class JsonHandler
  def call(context)
    context.json ok: true
  end
end

app.get "/h", HelloHandler.new
app.post "/ok", OkHandler.new
app.put "/json", JsonHandler      # class is instantiated per request
```

### CLI Options
- `-c, --config FILE`: Load a Rack `config.ru`
- `-f, --appfile FILE`: Load a Ruby file that sets `Butterscotch::CLI.app` (e.g., via `app.run`)
- `-o, --host HOST`: Bind host (default: `127.0.0.1`)
- `-p, --port PORT`: Bind port (default: `3000`)
- `-e, --env ENV`: Rack environment (default: `development`)
- `-s, --server NAME`: Rack server (default: `webrick` if available)
- `-v, --version`: Print version
- `-h, --help`: Show help

### Error Handling
- `app.error(ExceptionClass = StandardError) { |error, context| ... }`: Register per-exception handler
- `app.not_found { |context| ... }`: Custom 404 handler
- Unhandled errors return `500 Internal Server Error` by default


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/butterscotch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/butterscotch/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Butterscotch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/butterscotch/blob/master/CODE_OF_CONDUCT.md).
