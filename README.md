# Sitemap Generator

A simple command-line Sitemap generator tool. Useful for quickly auditing a website.

Distributed as a Ruby Gem [https://rubygems.org/gems/sitemap-generator], it is not intended to be a Search Engine sitemap or integrated CMS/Rails/etc. - there are plenty of other gems that do that well.

_NOTE_: LinkedIn have changed their policy and the API this depended on is no longer available, meaning this tool no longer works, and is no longer actively maintained as a result.

[![Gem Version](https://badge.fury.io/rb/sitemap-generator.svg)](http://badge.fury.io/rb/sitemap-generator)
[![Build Status](https://travis-ci.org/mefellows/sitemap-generator.svg)](https://travis-ci.org/mefellows/sitemap-generator)
## Getting started

    gem install sitemap-generator

## Examples

### Generate a standard CSV Sitemap file

The following command will generate a basic sitemap, listing all links recursively from the site, containing only URIs from the specified domain name (in this case, onegeek.com.au) and will save to a file named sitemap.csv

    sitemap generate http://www.onegeek.com.au/ sitemap.csv

### Generate a standard Sitemap JSON format

This command deliberately doesn't write to file in order to allow unix-style pipelining

    sitemap generate --format=json http://www.onegeek.com.au/

### Generate a Sitemap 3 levels deep

    sitemap generate --depth=3 http://www.onegeek.com.au/ sitemap.csv

### Generate a Sitemap containing links only on the specified URI

    sitemap generate --no-recursion http://www.onegeek.com.au/ sitemap.csv

### Generate a Sitemap that contains URI fragments and query strings

By default, URI fragments like ```foo.com/#!/some-page``` and query strings like ```foo.com/?bar=baz``` are ignored - they are generally duplicitous so sitemap-generator strips them off entirely. This lets them back in:

    sitemap generate --query-strings --fragments http://www.onegeek.com.au/ sitemap.csv

## Getting Help

    sitemap
    sitemap generate --help

## Alternatives?

So of course, after spending a few hours writing this I forgot that wget can do this for you, well basically anyway:

    wget --spider --recursive --no-verbose --output-file=wgetlog.txt http://somewebsite.com
    sed -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" wgetlog.txt | sed "s@&@\&amp;@" > sedlog.txt


# Website

## Run Server

foreman start
