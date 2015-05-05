require "heroku/command/base"
require "heroku/helpers/log_displayer"

# run one-off commands (console, rake)
#
class Heroku::Command::Run < Heroku::Command::Base

  # run COMMAND
  #
  # run an attached dyno
  #
  # -s, --size SIZE      # specify dyno size
  #
  #Example:
  #
  # $ heroku run -- bash
  # Running `bash` attached to terminal... up, run.1
  # ~ $
  #
  def index
    Heroku::JSPlugin.setup
    Heroku::JSPlugin.install('heroku-run') unless Heroku::JSPlugin.is_plugin_installed?('heroku-run')
    Heroku::JSPlugin.run('run', nil, ARGV[1..-1])
  end

  # run:detached COMMAND
  #
  # run a detached dyno, where output is sent to your logs
  #
  # -s, --size SIZE      # specify dyno size
  # -t, --tail           # stream logs for the dyno
  #
  #Example:
  #
  # $ heroku run:detached ls
  # Running `ls` detached... up, run.1
  # Use `heroku logs -p run.1` to view the output.
  #
  def detached
    command = args.join(" ")
    error("Usage: heroku run COMMAND") if command.empty?
    opts = { :attach => false, :command => command }
    opts[:size] = options[:size] if options[:size]

    app_name = app
    process_data = action("Running `#{command}` detached", :success => "up") do
      process_data = api.post_ps(app_name, command, opts).body
      status(process_data['process'])
      process_data
    end
    if options[:tail]
      opts = []
      opts << "tail=1"
      opts << "ps=#{process_data['process']}"
      log_displayer = ::Heroku::Helpers::LogDisplayer.new(heroku, app, opts)
      log_displayer.display_logs
    else
      display("Use `heroku logs -p #{process_data['process']} -a #{app_name}` to view the output.")
    end
  end
end
