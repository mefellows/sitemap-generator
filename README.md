# Sitemap Generator
A simple command-line Sitemap generator tool. Useful for quickly auditing a website.

## Getting started

    git clone https://github.com/mefellows/sitemap-generator
    cd sitemap-generator

### Generate a standard CSV Sitemap file
The following command will generate a basic sitemap, listing all links recursively from the site, containing only URIs from the specified domain name (in this case, onegeek.com.au) and will save to a file named sitemap.csv

    bin/sitemap generate http://www.onegeek.com.au/ sitemap.csv

### Generate a standard Sitemap JSON format

    bin/sitemap generate --format=json http://www.onegeek.com.au/ sitemap.json
  
### Generate a Sitemap restricting to the URI provided

    bin/sitemap generate --recursive=false http://www.onegeek.com.au/ sitemap.csv
    
### Generate a Sitemap restricting indexed URLs to only those starting with '/journal'

    bin/sitemap generate --restrict-path=/journal http://www.onegeek.com.au/ sitemap.csv
    
        
## Getting Help

    bin/sitemap
    bin/sitemap generate --help
    
## Alternatives?

So of course, after spending an hour writing this I forgot that wget can do this for you, well basically anyway:

    wget -r --delete-after <todo>
