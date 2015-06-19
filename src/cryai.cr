require "sqlite3"
require "json"

module CryAI

  class DB
    def initialize(@words_file, @lines_file)
      @words = {} of String => Array
      @lines = {} of Int32 => {String, Int32}
      load_data
    end

    def write_data
      File.write(@words_file, @words.to_json)
      File.write(@lines_file, @lines.to_json)
    end

    def load_data
      if File.exists?  @words_file
        f = File.read @words_file
        unless f.is_a?(Nil)
          @words = JSON.parse f
        end
      end
      puts @words
      if File.exists? @lines_file
        f = File.read @lines_file
        unless f.is_a?(Nil)
          @lines = JSON.parse f
        end
      end
      puts @lines
    end
  end

  class CryAI
    @@replacements = {
        '\n' => "",
        '\r' => "",
        '"' => "",
        '?' => "?.",
        '!' => "!.",
    }

    def initialize(words_file = "words.json", lines_file = "lines.json")
      @db = DB.new words_file, lines_file
    end

    private def prepare_msg msg
      msg.gsub(@@replacements).split(".").map {|line| line.strip}
    end

    private def learn_line line
      words = line.split
      line_hash = line.hash
      unless @db.@words[line_hash]?
        @db.@words[line_hash] = {line, 1}
        words.each_index do |index|
          word = words[index]
          if @db.@words[word]?
            @db.@words[word] << {line_hash, index}
          else
            @db.@words[word] = [{line_hash, index}]
          end
        end
      else
        @db.@words[line_hash][1] += 1
      end
      @db.write_data
    end

    def learn msg
      lines = prepare_msg msg
      lines.each do |line|
        learn_line line
      end
    end
  end
end

my_ai = CryAI::CryAI.new
my_ai.learn("Hello, world! Yeah, nice world :)")
