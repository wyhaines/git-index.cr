require "option_parser"

struct GitIndex
  module Config
    def self.parse_command_line
      config = Hash(String, Bool | String | Symbol).new
      {
        "database" => "sqlite3://#{ENV["HOME"]}/.git-index.db",
        "recurse"  => false,
        "verbose"  => false,
        "dryrun"   => false,
      }.each { |k, v| config[k] = v }

      _commands = [] of Symbol
      options = OptionParser.new do |opts|
        opts.banner = <<-EBANNER
        Usage: git-index [OPTIONS] PATH1 PATH2 PATHn

        This tool takes one or more paths and checks them for the presence of a git repository. If one exists, it writes a record into the database of the first and second commit hashes of the repository and the path to the repository.
        EBANNER
        opts.separator ""
        opts.on("-d", "--database [PATH]", "The database file to write to. Defaults to $HOME/.git-index.db") do |path|
          config["database"] = "sqlite3://#{path}"
        end
        opts.on("-r", "--recurse", "Recursively search through the provided directories for git repositories.") do
          config["recurse"] = true
        end
        opts.on("-l", "--list", "List the known repositories") do
          _commands << :list
        end
        opts.on("-q", "--query", "The command line arguments are assumed to be hashes to query for in the database. Matches will be returned, one per line, in the same order the hashes appear on the command line.") do |_hash|
          _commands << :query
        end
        opts.on("-x", "--delete", "The command line arguments are assumed to be hashes or paths to delete from the databse.") do
          _commands << :delete
        end
        opts.on("-i", "--insert", "The command line arguments are assumed to be paths to check for git repositories. This is the default mode of operation.") do
          _commands << :insert
        end
        opts.on("-v", "--verbose", "Provide extra output about actions") do
          config["verbose"] = true
        end
        opts.on("-n", "--dry-run", "Find git repositories, but do not actually store them in the database. This option doesn't do much without also specifying --verbose.") do
          config["dryrun"] = true
        end
        opts.on("-h", "--help", "Show this help") do
          # NOOP. If there are no other commands, help will be shown.
        end
        opts.on("--version", "Output #{version_string}") do
          puts version_string
          exit
        end
      end
      options.parse

      # Post-parsing command determination.
      if _commands.size > 1
        raise ArgumentError.new("Specify only a single command mode (-l, -q, -d, -i)")
      elsif !_commands.empty?
        config["command"] = _commands.first
      elsif !ARGV.empty?
        # There us something else on the command line. Assume that it is
        # a path, and default to :insert mode.
        config["command"] = :insert
      else
        # No commands. No other args. Gosh, there's nothing to do. Let's
        # give some help.
        config["command"] = :noop
        puts options
      end

      config
    end

    def self.version_string
      "git-index v#{GitIndex::VERSION}-crystal"
    end
  end
end
