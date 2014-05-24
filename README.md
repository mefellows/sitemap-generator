# Sitemap Generator
A simple command-line Sitemap generator tool. Useful for quickly auditing a website.

## Getting started

    gem install sitemap-generator

### Getting started with code

    git clone https://github.com/mefellows/sitemap-generator
    cd sitemap-generator
    bundle install

### create a re-usable

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
    
## Getting Help

    sitemap
    sitemap generate --help
    
## Alternatives?

So of course, after spending a few hours writing this I forgot that wget can do this for you, well basically anyway:

    wget -r --delete-after <todo>

