# Thieve

## What is this?

This ruby gem searches through provided directories, looking for
private/public keys and certs. Then extracts, fingerprints, and
attempts to match keys with certs.

## How to install

```
$ gem install thieve
```

## Usage

```
$ thieve --help
Usage: thieve [OPTIONS] <dir>...

DESCRIPTION
    Searches through provided directories, looking for private/public keys and
    certs. Then extracts, fingerprints, and attempts to match keys with certs.

OPTIONS
    -e, --export=DIRECTORY  Export keys to specified directory
    -h, --help              Display this help message
    -i, --ignore=REGEX      Ignore dirs/files matching REGEX
        --nocolor           Disable colorized output
    -p, --private-only      Only export/show private keys and matching certificates
        --version           Show version
    -v, --verbose           Show backtrace when error occurs
```

## Links

- [Source](https://gitlab.com/mjwhitta/thieve)
- [RubyGems](https://rubygems.org/gems/thieve)

## TODO

- Better README
- RDoc
