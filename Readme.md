# Utils for parsing and processing English Wikipedia category names

## Aggregated Rake task

tldr;

```bash
wiki$ export WIKI_DATA=/path/to/data 
wiki$ export WIKI_DB=/path/to/db 
wiki$ export STANFORD_PARSER=path/to/parser
wiki$ export STANFORD_MODELS=path/to/models
wiki$ export JAVA_HOME=path/to/jre
wiki$ rake
```

is equivalent to:

* rake parse:filter
* rake parse:suffix
* rake parse:parse
* rake parse:convert
* rake parse:join
* rake parse:heads

## Individual scripts syntax

###  Clean names

Remove commas and brackets for better parsing

```bash
category-parsing$ utils/filter_commas_and_brackets.rb -c categories.csv -o preprocessed_categories.csv
```

### Add 'are good' suffix

Prepare data for Stanford Parser by adding suffix "are good." to category names

```bash
category-parsing$ utils/add_suffix.rb -c preprocessed_categories.csv > preprocessed_categories_to_parse.txt
```

### Parse 

Parse the category names using Stanford Parser. You need the Stanford parser or
the stanford NLP toolkit installed in your system. It also requires Java to
work. Parsing all English categories takes a lot of time (several days on one
core).

```bash
java -Xmx4g -cp stanford-parser.jar:stanford-parser-3.3.1-models.jar edu.stanford.nlp.parser.lexparser.LexicalizedParser -outputFormat "oneline, typedDependenciesCollapsed" -outputFormatOptions "markHeadNodes" -sentences newline -retainTmpSubcategories edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz preprocessed_categories_to_parse.txt > preprocessed_categories.parsed
```

###  Merge 

Merge parsing results with category names into a CSV file.

```bash
category-parsing$ utils/join_parsed_data.rb -s preprocessed_categories.csv -p preprocessed_categories.parsed -o parsed_preprocessed_categories.csv
```

### Filter 

Filter administrative, list, stub and etc. categories that are not interesting
from the POV of cycloped.io.

```bash
category-parsing$ utils/filter_administartive.rb -p parsed_preprocessed_categories.csv -a administrative.csv -o parsed_preprocessed_categories_wo_administrative.csv
```

### Find heads

Fix plurals using data from the English Wiktionary and find noun heads using a set of heuristics.

```bash
category-parsing$ utils/parse_category_names.rb -c parsed_preprocessed_categories_wo_administrative.csv -o parsed_with_heads.csv -e errors
```

### Load heads to ROD

**This is run in `wiki` subproject**.

```bash
wiki$ utils/categories/load_parses.rb -d data/en-2013 -f ../category-parsing/parsed_with_heads.csv
```

### Statistics

Compute statistics for (non-letter) characters and words occurring in category
names. 

```bash
category-parsing$ utils/chars_stats.rb -c parsed_with_heads.csv
category-parsing$ utils/words_stats.rb -c parsed_with_heads.csv > words_stats
```

## Credits

* Krzysztof Wróbel (djstrong)
* Aleksander Smywiński-Pohl (apohllo)
