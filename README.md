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

Example `config.ru`:

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

app.group "/api" do |g|
  g.get "/ping" do |context|
    context.json ok: true, ip: context.ip
  end
end

run app
```

Run with:

```bash
rackup
```

### Routing
- **Methods:** `get`, `post`, `put`, `patch`, `delete`, `options`, `head`, `trace`, `any`
- **Params:** `:id` like `/users/:id`, splat `*` like `/files/*`
- **Groups:** `app.group "/api" { |g| g.get "/ping" { ... } }` (nestable)
- **HEAD:** Uses matching `GET` route, returns empty body and sets `Content-Length` when possible.

### Context API
- `req`: Rack request object (`Rack::Request`)
- `params`: Path parameters hash
- `ip`: Client IP shortcut
- `status(code)`: Set response status (default 200)
- `header(key, value)`: Set a response header; `header(key)` to get
- `headers(hash)`: Merge multiple headers; returns current headers
- `text(body, status: nil, headers: {})`: Return plain text
- `html(body, status: nil, headers: {})`: Return HTML
- `json(obj = nil, status: nil, headers: {}, **kw)`: Return JSON
- `redirect(location, status: 302, headers: {})`: Redirect helper
- `halt(code = nil, body = nil, headers: {})`: Immediately stop and return given response
- `request_header(name)`: Read request header (e.g. `HTTP_X_REQUEST_ID`)
- `set_header(key, value)`: Alias of `header` (does not return Rack response)

### Error Handling
- `app.error(ExceptionClass = StandardError) { |error, context| ... }`: Register per-exception handler
- `app.not_found { |context| ... }`: Custom 404 handler
- On unhandled errors, returns `500 Internal Server Error` by default


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/butterscotch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/butterscotch/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Butterscotch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/butterscotch/blob/master/CODE_OF_CONDUCT.md).
