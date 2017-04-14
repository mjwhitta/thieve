# Thieve

## What is this?

This ruby gem searches through provided directories, looking for
private/public keys and certs. Then extracts, fingerprints, and
attempts to match keys with certs.

## How to install

```bash
$ gem install thieve
```

## Usage

```
$ thieve --help
Usage: thieve [OPTIONS] <dir>...

DESCRIPTION
    Searches through provided directories, looking for private/public
    keys and certs. Then extracts, fingerprints, and attempts to match
    keys with certs.

OPTIONS
    -e, --export=DIRECTORY  Export keys to specified directory
    -h, --help              Display this help message
    -i, --ignore=PATTERN    Ignore dirs/files matching PATTERN
        --nocolor           Disable colorized output
    -v, --verbose           Show backtrace when error occurs
```

## Links

- [Homepage](https://mjwhitta.github.io/thieve)
- [Source](https://gitlab.com/mjwhitta/thieve)
- [Mirror](https://github.com/mjwhitta/thieve)
- [RubyGems](https://rubygems.org/gems/thieve)

## TODO

- Better README
- RDoc
