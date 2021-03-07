require "./spec_helper"

describe GitIndex::Config do
  it "returns a version string" do
    GitIndex::Config.version_string.should match(/git-index v#{GitIndex::VERSION}-crystal/)
  end

  it "has reasonable defaults if given no arguments" do
    ARGV.clear
    config = GitIndex::Config.parse_command_line
    config["database"].should match(/^sqlite.*.git-index.db$/)
    config["command"].should eq :noop
  end

  it "sets dry-run with the long form" do
    ARGV.replace ["--dry-run"]
    config = GitIndex::Config.parse_command_line
    config["dryrun"].should be_true
  end

  it "sets dry-run with the short form" do
    ARGV.replace ["-n"]
    config = GitIndex::Config.parse_command_line
    config["dryrun"].should be_true
  end

  it "sets verbose with the long form" do
    ARGV.replace ["--verbose"]
    config = GitIndex::Config.parse_command_line
    config["verbose"].should be_true
  end

  it "sets verbose with the short form" do
    ARGV.replace ["-v"]
    config = GitIndex::Config.parse_command_line
    config["verbose"].should be_true
  end

  it "sets recurse with the long form" do
    ARGV.replace ["--recurse"]
    config = GitIndex::Config.parse_command_line
    config["recurse"].should be_true
  end

  it "sets recurse with the recurse form" do
    ARGV.replace ["-r"]
    config = GitIndex::Config.parse_command_line
    config["recurse"].should be_true
  end

  it "allows the database to be specified with the long form" do
    ARGV.replace ["--database", "/tmp/gi.db"]
    config = GitIndex::Config.parse_command_line
    config["database"].should eq "sqlite3:///tmp/gi.db"
  end

  it "allows the database to be specified with the short form" do
    ARGV.replace ["-d", "/tmp/gi.db"]
    config = GitIndex::Config.parse_command_line
    config["database"].should eq "sqlite3:///tmp/gi.db"
  end

  it "raises an error if more than one command argument is given" do
    ARGV.replace ["-l", "-q"]
    expect_raises(ArgumentError) { GitIndex::Config.parse_command_line }
  end

  it "sets implied :insert command if just given a path" do
    ARGV.replace ["/tmp/foo"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :insert
    ARGV[0].should eq "/tmp/foo"
  end

  it "explicit insert is understood in the long form" do
    ARGV.replace ["--insert", "/tmp/foo"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :insert
    ARGV[0].should eq "/tmp/foo"
  end

  it "explicit insert is understood in the short form" do
    ARGV.replace ["-i", "/tmp/foo"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :insert
    ARGV[0].should eq "/tmp/foo"
  end

  it "list is understood in the long form" do
    ARGV.replace ["--list"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :list
  end

  it "list is understood in the short form" do
    ARGV.replace ["-l"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :list
  end

  it "query is understood in the long form" do
    ARGV.replace ["--query", "abc"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :query
    ARGV[0].should eq "abc"
  end

  it "query is understood in the short form" do
    ARGV.replace ["-q", "abc"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :query
    ARGV[0].should eq "abc"
  end

  it "delete is understood in the long form" do
    ARGV.replace ["--delete", "abc"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :delete
    ARGV[0].should eq "abc"
  end

  it "delete is understood in the short form" do
    ARGV.replace ["-x", "abc"]
    config = GitIndex::Config.parse_command_line
    config["command"].should eq :delete
    ARGV[0].should eq "abc"
  end
end
