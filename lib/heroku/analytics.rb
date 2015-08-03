class Heroku::Analytics
  extend Heroku::Helpers

  def self.record(command)
    return if skip_analytics
    File.open(path, 'a') do |f|
      f.write("#{command}|#{Time.now.to_i}\n")
    end
  rescue
  end

  def self.submit
    return if skip_analytics
    lines = File.read(path).split("\n")
    return if lines.count < 10 # only submit if we have 10 entries to send
    fork do
      commands = lines.map do |line|
        line = line.split('|')
        {command: line[0], timestamp: line[1].to_i}
      end
      payload = {
        user:     user,
        commands: commands
      }
      Excon.post('https://heroku-cli-analytics.herokuapp.com/record', body: JSON.dump(payload))
      File.truncate(path, 0)
    end
  rescue
  end

  private

  def self.skip_analytics
    Heroku::Config[:skip_analytics] ||
      ['0', 'true'].include?(ENV['HEROKU_SKIP_ANALYTICS'])
  end

  def self.path
    File.join(Heroku::Helpers.home_directory, ".heroku", "analytics")
  end

  def self.user
    credentials = Heroku::Auth.read_credentials
    credentials[0] if credentials
  end
end
