require "sqlite3"
require "find"
require "./git-index/*"
require "uri"

struct GitIndex
  # @config : Hash(String, Bool | String | Symbol)

  # def initialize
  #   @config = Config.parse_command_line
  # end

  def initialize(@config : Hash(String, Bool | String | Symbol) = Config.parse_command_line)
  end

  def run
    db = database
    case @config["command"]
    when :delete
      delete_records(db)
    when :insert
      index_git_repositories(db, git_directories)
    when :list
      list_records(db)
    when :query
      query_records(db)
    end
  ensure
    db.close if !db.nil?
  end

  def database
    db = DB.open @config["database"].to_s

    begin
      db.query("select 1 from repositories") do |row|
        break
      end
    rescue
      db.exec <<-SQL
      create table repositories (
        hash varchar(160),
          path varchar(250),
            url varchar(250)
      )
      SQL
    end

    db
  end

  def git_directories
    if @config["recurse"]
      untrimmed_directories = [] of String
      ARGV.each do |base_path|
        Find.find(base_path) do |path|
          Find.prune if path.includes? ".git"
          Find.prune unless File.directory?(path)
          Find.prune if system("git -C #{File.join(path, "..")} rev-parse --is-inside-work-tree > /dev/null 2>&1")
          untrimmed_directories << File.expand_path(path)
        end
      end
    else
      untrimmed_directories = ARGV
    end

    untrimmed_directories.select do |dir|
      system("git -C #{dir} rev-parse --is-inside-work-tree > /dev/null 2>&1")
    end
  end

  def index_git_repositories(db, dirs)
    dirs.each do |dir|
      codes = `git -C #{dir} rev-list --parents HEAD | tail -2`.split("\n")
      remote = `git -C #{dir} config --get remote.origin.url`.strip
      hash = codes.size > 1 ? codes.first : codes.last

      if hash =~ /^([\w\d]+)\s+([\w\d]+)$/
        hash = "#{$2}#{$1}"
      end
      db.exec("INSERT INTO repositories (hash, path, url) VALUES (?, ?, ?)", hash, File.expand_path(dir), remote) unless @config["dryrun"]
      puts "#{hash} -> #{File.expand_path(dir)}" if @config["verbose"]
    end
  end

  def delete_records(db)
    ARGV.each do |path_or_hash|
      if !URI.parse(path_or_hash).scheme.nil?
        puts "deleting url #{path_or_hash}" if @config["verbose"]
        db.exec("DELETE from repositories WHERE url = ?", path_or_hash) unless @config["dryrun"]
      elsif File.exists?(File.expand_path(path_or_hash))
        path_or_hash = File.expand_path(path_or_hash)
        puts "deleting path #{path_or_hash}" if @config["verbose"]
        db.exec("DELETE FROM repositories WHERE path = ?", path_or_hash) unless @config["dryrun"]
      else
        puts "deleting hashes like #{path_or_hash}" if @config["verbose"]
        db.exec("DELETE FROM repositories where hash like ?", "#{path_or_hash}%") unless @config["dryrun"]
      end
    end
  end

  def list_records(db)
    puts "hash,path,url"
    db.query("SELECT hash, path, url FROM repositories") do |rs|
      rs.each do
        puts [rs.read(String), rs.read(String), rs.read(String)].join(",")
      end
    end
  end

  def query_records(db)
    ARGV.each do |hash_or_url|
      db.query("SELECT hash, path, url from repositories WHERE hash like ? or url = ?", "#{hash_or_url}%", hash_or_url) do |rs|
        rs.each do
          puts "#{rs.read(String)}: #{rs.read(String)}|#{rs.read(String)}"
        end
      end
    end
  end
end

GitIndex.new.run
