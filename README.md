# Json Path RFC 9535

A Ruby implementation of RFC 9535.

Like XPath is a query language for XML, JsonPath is a query language for JSON. This gem aims to be an implementation of RFC 9535. Unlike tha original JsonPath description (http://goessner.net/articles/JsonPath/), RFC 9535 is strictly normative, which ideally should leave open fewer doors for inconsistencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_path_rfc9535', '~> 1.0'
```

And then execute:

```bash
$ bundle
```

Or you can install the gem on its own:

```bash
gem install json_path_rfc9535
```

## Usage

Parse the Json into a `JsonPath::Doc` instance...

```ruby
doc = JsonPath::Doc(<<~JSON)
{ 
  "store": {
    "book": [
      { 
        "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      { 
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      { 
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      { 
        "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 399
    }
  }
}
JSON
```

... and then query it.

```ruby
doc.query('$.store.bicycle.color')
```

If you already parsed the Json, you can use that instead of the Json string:

```ruby
json = JSON.parse('...')
...
doc = JsonPath::Doc(json)
```

The query returns an `Enumerable`, which also has methods to retrieve the values or the paths of all the retrieved nodes:

```ruby
results = doc.query('$.store.book.*.category')
results.count
# => 4
results.values
# => ["reference", "fiction", "fiction", "fiction"]
results.paths
# => ["$['store']['book'][0]['category']", "$['store']['book'][1]['category']", "$['store']['book'][2]['category']", "$['store']['book'][3]['category']"]
```

You can also query it further:

```ruby
results = doc.query('$.store.book[?(@.price > 10)]')
results.paths
# => ["$['store']['book'][1]", "$['store']['book'][3]"]
results.query('$.author').values
# => ["Evelyn Waugh", "J. R. R. Tolkien"]
```

Alternatively, you can query the single nodes:

```ruby
results.flat_map { _1.query('$.author').values }.join(', ')
# => "Evelyn Waugh, J. R. R. Tolkien"
```

This gem implements most of RFC 9535, with the exception of [function extensions](https://datatracker.ietf.org/doc/html/rfc9535#name-function-extensions) and the related [type system](https://datatracker.ietf.org/doc/html/rfc9535#name-type-system-for-function-ex). It also relies on the underlying Ruby interpreter for string evaluation, meaning that characters don't need to be double-escaped.

## Plans for future development

- Function extensions
  - Function extensions type system

## Version numbers

Json Path RFC 9535 loosely follows [Semantic Versioning](https://semver.org/), with a hard guarantee that breaking changes to the public API will always coincide with an increase to the `MAJOR` number.

Version numbers are in three parts: `MAJOR.MINOR.PATCH`.

- Breaking changes to the public API increment the `MAJOR`. There may also be changes that would otherwise increase the `MINOR` or the `PATCH`.
- Additions, deprecations, and "big" non breaking changes to the public API increment the `MINOR`. There may also be changes that would otherwise increase the `PATCH`.
- Bug fixes and "small" non breaking changes to the public API increment the `PATCH`.

Notice that any feature deprecated by a minor release can be expected to be removed by the next major release.

## Changelog

Full list of changes in [CHANGELOG.md](CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moku-io/json_path_rfc9535.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
