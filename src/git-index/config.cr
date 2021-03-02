require "option_parser"

class GitIndex
  module Config
    def self.parse_command_line
      config = Hash(String, Bool | String | Symbol).new
      {
        "database" => "sqlite3://#{ENV["HOME"]}/.git-index.db",
        "recurse"  => false,
        "verbose"  => false,
        "dryrun"   => false
    }.each {|k,v| config[k] = v}

    leftover_argv = [] of String

      options = OptionParser.new do |opts|
        opts.banner = <<-EBANNER
        Usage: git-index [OPTIONS] PATH1 PATH2 PATHn

        This tool takes one or more paths and checks them for the presence of a git repository. If one exists, it writes a record into the database of the first and second commit hashes of the repository and the path to the repository.
        EBANNER
        opts.separator ""
        opts.on("-d", "--database [PATH]", "The database file to write to. Defaults to $HOME/.git-index.db") do |path|
          config["database"] = path
        end
        opts.on("-r", "--recurse", "Recursively search through the provided directories for git repositories.") do
          config["recurse"] = true
        end
        opts.on("-i", "--insert", "The command line arguments are assumed to be paths to check for git repositories. This is the default mode of operation.") do
          config["command"] = :insert
        end
        opts.on("-x", "--delete", "The command line arguments are assumed to be hashes or paths to delete from the databse.") do
          config["command"] = :delete
        end
        opts.on("-l", "--list", "List the known repositories") do
          config["command"] = :list
        end
        opts.on("-q", "--query", "The command line arguments are assumed to be hashes to query for int he database. Matches will be returned, one per line, in the same order the hashes appear on the command line.") do |hash|
          config["command"] = :query
        end
        opts.on("-v", "--verbose", "Provide extra output about actions") do
          config["verbose"] = true
        end
        opts.on("-n", "--dry-run", "Find git repositories, but do not actually store them in the database. This option doesn't do much without also specifying --verbose.") do
          config["dryrun"] = true
        end
        opts.on("--help", "Show this help") do
          puts opts
          exit
        end
        opts.on("--version", "Output #{version_string}") do
          puts version_string
          exit 0
        end

        opts.invalid_option {|invalid_option| leftover_argv << invalid_option}

      end

      options.parse

      ARGV.replace(leftover_argv) if leftover_argv.any?

      config["command"] ||= :insert
      config
    end

    def self.version_string
      "git-index v#{GitIndex::VERSION}-crystal"
    end
  end
end
