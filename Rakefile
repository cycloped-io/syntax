task :default => [:'parse:filter', :'parse:suffix', :'parse:parse', :'parse:convert', :'parse:join', :'parse:heads']

namespace :parse do
  parser = ENV['STANFORD_PARSER']
  models = ENV['STANFORD_MODELS']
  wikipedia_path = ENV['WIKI_DATA']
  db_path = ENV['WIKI_DB']
  java = ENV['JAVA_HOME']

  if wikipedia_path.nil?
    puts 'WIKI_DATA has to be set'
    exit
  end

  desc 'Filter commas and brackets'
  task :filter do
    puts `utils/filter_commas_and_brackets.rb -c #{wikipedia_path}/non_administrative.csv -o #{wikipedia_path}/preprocessed_categories.csv`
  end

  desc 'Generate text file with suffixed category names'
  task :suffix do
    puts `utils/add_suffix.rb -c #{wikipedia_path}/preprocessed_categories.csv > #{wikipedia_path}/preprocessed_categories_to_parse.txt`
  end

  desc 'Parse category names using Stanford Parser'
  task :parse do
    if parser.nil?
      puts 'STANFORD_PARSER has to be set'
      exit
    end
    if models.nil?
      puts 'STANFORD_MODELS has to be set'
      exit
    end
    if java.nil?
      puts 'JAVA_HOME has to be set'
      exit
    end
    puts `#{java}/bin/java -Xmx4g -cp #{parser}/stanford-parser.jar:#{models} edu.stanford.nlp.parser.shiftreduce.ShiftReduceParser -outputFormat "oneline, typedDependenciesCollapsed" -outputFormatOptions "markHeadNodes" -retainTmpSubcategories -model edu/stanford/nlp/models/srparser/englishSR.beam.ser.gz #{wikipedia_path}/preprocessed_categories_to_parse.txt > #{wikipedia_path}/preprocessed_categories.parsed.sr`
    #puts `#{java}/bin/java -Xmx4g -cp #{parser}/stanford-parser.jar:#{models} edu.stanford.nlp.parser.nndep.DependencyParser -outputFormat "oneline, typedDependenciesCollapsed" -outputFormatOptions "markHeadNodes" -sentences newline -retainTmpSubcategories -model edu/stanford/nlp/models/parser/nndep/PTB_CoNLL_params.txt.gz -textFile #{wikipedia_path}/preprocessed_categories_to_parse.txt -outFile #{wikipedia_path}/preprocessed_categories.parsed`
    #puts `#{java}/bin/java -Xmx4g -cp #{parser}/stanford-parser.jar:#{models} edu.stanford.nlp.parser.lexparser.LexicalizedParser -outputFormat "oneline, typedDependenciesCollapsed" -outputFormatOptions "markHeadNodes" -sentences newline -retainTmpSubcategories edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz #{wikipedia_path}/preprocessed_categories_to_parse.txt > #{wikipedia_path}/preprocessed_categories.parsed`
  end

  desc 'Convert parsed data to CSV'
  task :convert do
    puts `utils/parsed_data_to_csv.rb -s #{wikipedia_path}/preprocessed_categories_to_parse.txt -p #{wikipedia_path}/preprocessed_categories.parsed -o #{wikipedia_path}/parsed_preprocessed_categories.csv`
  end

  desc 'Join parsed data'
  task :join do
    puts `utils/join_lines.rb csv -a #{wikipedia_path}/preprocessed_categories.csv -x CSV -b #{wikipedia_path}/parsed_preprocessed_categories.csv -y CSV -o #{wikipedia_path}/joined_parsed_preprocessed_categories.csv`
  end

  desc 'Find head nouns'
  task :heads do
    puts `utils/parse_category_names.rb -c #{wikipedia_path}/joined_parsed_preprocessed_categories.csv -o #{wikipedia_path}/categories_with_heads.csv -e #{wikipedia_path}/head_errors`
  end

end
