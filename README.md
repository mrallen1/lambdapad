# LambdaPad: Erlang Powered Site Generation, FTW!

LambdaPad is currently a work in process. It's pretty functional though. And
it's *awesome*.

LambdaPad can be used to generate a
[static site](http://staticsitegenerators.net). Here's the gist:

- Maintain *data* in various formats
- Maintain *templates* and related *static content*
- Use an Erlang module to generate a static site

Sound crazy? An Erlang module? Why not YAML, Ruby, JavaScript or some other
super easy to use and understand format?

Because *Erlang* is super easy to use and understand! It's *better* than these
other formats and languages. This project proves it.

Here's basic "Hello World" web site, as specified in a LambdaPad Erlang module:

```erlang
-module(index).

data(_) -> #{ msg => "Hello LambdaPad!" }.

site(_) -> #{ "index.html" => {string, "{{ msg }}"} }.

```

To create a site, run `lpad-gen` in your project directory and you're done!

Too hard? Shucks, just follow these super simple steps to try it:

1. Grab the [lambdapad repo](https://github.com/gar1t/lambdapad) from github:

	```bash
	$ git clone https://github.com/gar1t/lambdapad.git
	```

2. Change to the local `lambdapad` directory and run make:

	```bash
	$ cd lambdapad
	$ make
	```

3. Change to the `samples/hello` directory and run make:

	```
	$ cd samples/hello
	$ make
	```

4. Open `lambdapad/samples/hello/site/index.html` in your browser

To understand what's going on, just read the page you just opened!

## Approach

A site is defined by a single `index.erl` module in the root of a project
directory. The module must provide two functions (which are auto exported):

- `data(Args) -> ...`
- `site(Data) -> ...`

The `data()` function defines the *data* used to generate the site structure
and content. It takes a single `Args` argument, which is a list of the
arguments passed to `lpad-gen`. It returns a list (or map) of data loaders that
are used to create a fully resolved data value. That data value is provided to
the `site()` function and is available to all site generators.

The `site()` function defines a list of generators. It takes a single `Data`
argument, which is the fully resolved data value created by the data loaders
from `data()`.

When `lpad-gen` is run, LambdaPad generates a site using the `index.erl`
module:

1. Data loaders are provided by `data()`
2. Data loaders are used to create *Data*
2. Generators are created by `site()`
3. Generators are used to create the site content

That's it.

LambdaPad doesn't like implicit behavior. There's one authoritative module used
to create the site. There's nothing weird lurking in subdirectories,
metadata.yaml files, or other dark corners.

Data can be loaded from a variety of sources (see
[Data Loaders](#data-loaders)) below).

Various generators can be used to create site content (see
[Generators](#generators) below).

## Data Loaders

### `{eterm, File`}

To load an Erlang term file as data, use `{eterm, File`}. The term
should be a single map or Erlang property list.

Here's a sample use:

```erlang
data(_) -> #{params => {eterm, "params.config"}.
```

The Eterm file `params.config` might look like:

```erlang
#{
  site_title => "My Cool Site",
  site_style => bright_green,
  plugins    => [twitter, facebook]
}.
```

A template could use the data like this:

```html
<html class="{{ params.site_style }}">

  <h1>{{ params.site_title }}</h1>

  {% for plugin in params.plugins %}
  <script src="{{ plugin}}.js"></script>
  {% endfor %}

</html>
```

This is an easy way to provide structured data for your site. If you want to
provide markup content, use the `markdown` loader.

Note that you must terminate the single Erlang term with a period `.`

Below are more examples.

A list of colors:

```erlang
[red, blue, green].
```

A list of shapes, using maps:

```erlang
[
  #{
    shape => circle,
	color => red
  },
  #{
    shape => square,
	color => blue
  },
  #{
    shape => triangle,
	color => green
  }
].
```

See the [samples/hello_eterm](samples/hello_eterm) for a working example.

### `{markdown, File}`

You can load Mardown files as data using `{markdown, File}`. For example:

```erlang
data(_) -> #{about => {markdown, "about.md"}}.
```

Here's a sample `about.md` file:

```markdown
---
body_class: bright green
body_id:    about
---
This is a sample markdown file that can be used for the "About" section
of a website. LambdaPad supported markdown lets you:

- Specify text content
- Format text for use in web paged
- Provide parameters/metadata in an optional header section

Pretty cool!
```

Here's a template that  uses the markdown:

```html
<html>
  <body id="{{ about.body_id }}" class="{{ about.body_class }}">
  {{ about|markdown_to_html }}
  </body>
</html>
```

See the [samples/hello_markdown](samples/hello_markdown) for a working example.

### `{json, File}`

You can load a JSON file using `{json, File}`.

Like this:

```erlang
data(_) -> {json, "data.json"}.
```

Here's `data.json`:

```json
{
  "msg": "This data came from the venerable JSON format!"
  "colors": ["red", "green", "blue"]
}
```

Here's a template:

```html
<html>
  <p>{{ msg }}</p>
  <p>See the pretty colors:</p>
  <ul>
    {% for color in colors %}
	<li>{{ color }}
	{% endfor %}
  </ul>
  </body>
</html>
```

See the [samples/hello_json](samples/hello_json) for a working example.

## Generators

### `{template, Template}`

You can use a
[Django template](https://docs.djangoproject.com/en/dev/topics/templates) to
generate content using the site data. The template is a file relative to the
site root.

For example:

```erlang
site(_) -> #{ "site/index.html" => {template, "index.html"} }.
```

Templates have access to site site data, which is generated by the loaders from
`data()`.

See the [samples/hello](samples/hello) for a working example.

### `{file, File`}

You can copy a single file to the site using `{file, File}`.

For example:

```erlang
site(_) -> #{ "site/css/styles.css" => {file, "css/styles.css"} }.
```

### `{files, Pattern}`

You can copy files matching a pattern to the site using `{files, Pattern}`.

For example:

```erlang
site(_) -> #{ "site/css/*.css" => {file, "assets/*.css"} }.
```

### `{string, String}`

You can generate content using `{string, String}` where `String` is a well
formed snippet of Django template.

This is generally used for hello world examples and doesn't have an obvious
practical application.

# System Requirements

- Non-windows (for make support - see next point)
- Developer configure/make big boy environment
- Erlang R17 (need map support, the way it is)

## To Do

See [TODO.md](TODO.md) for a list of planned enhancements.
