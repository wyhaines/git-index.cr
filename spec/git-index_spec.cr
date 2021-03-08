require "./spec_helper"

describe GitIndex do
  it "works" do
    ARGV.replace ["--database",".git-index.db","-i","."]
    gi = GitIndex.new
    db = gi.database
    dirs = gi.git_directories
    dirs.should eq ["."]

    processed1 = gi.index_git_repositories(db, dirs)
    processed1.size.should eq 1
    processed1[0].size.should eq 3
    # -----
    ARGV.replace ["--database",".git-index.db","-l"]
    gi = GitIndex.new
    processed2 = gi.list_records(db)
    processed2.size.should eq 1
    processed2[0].size.should eq 3
    processed2.should eq processed1
    # -----
    ARGV.replace ["--database",".git-index.db","-q","git-index"]
    gi = GitIndex.new
    processed3 = gi.list_records(db)
    processed3.size.should eq 1
    processed3[0].size.should eq 3
    processed3.should eq processed1
    # -----
    ARGV.replace ["--database",".git-index.db","-x",processed3[0][2]]
    gi = GitIndex.new
    processed4 = gi.delete_records(db)
    processed4.size.should eq 1
    processed4[0].size.should eq 3
    processed4.should eq processed1
    # -----
    ARGV.replace ["--database",".git-index.db","-l"]
    gi = GitIndex.new
    processed5 = gi.list_records(db)
    pp processed5
    processed5.empty?.should be_true
  ensure
    File.delete(".git-index.db")
  end
end
