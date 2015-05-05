require "spec_helper"
require "heroku/command/run"
require "heroku/helpers"

describe Heroku::Command::Run do

  include Heroku::Helpers

  before(:each) do
    stub_core
    api.post_app("name" => "example", "stack" => "cedar")
  end

  after(:each) do
    api.delete_app("example")
  end

  describe "run:detached" do
    it "runs a command detached" do
      stderr, stdout = execute("run:detached bin/foo")
      expect(stderr).to eq("")
      expect(stdout).to eq <<-STDOUT
Running `bin/foo` detached... up, run.1
Use `heroku logs -p run.1 -a example` to view the output.
STDOUT
    end

    it "runs with options" do
      stub_core.read_logs("example", [
        "tail=1",
        "ps=run.1"
      ])
      execute "run:detached bin/foo --tail"
    end
  end
end
