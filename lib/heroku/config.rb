class Heroku::Config
  extend Heroku::Helpers

  def self.[](key)
    config[key.to_s]
  end

  private

  def self.config
    @config ||= JSON.parse(File.read(path)) rescue {}
  end

  def self.path
    File.join(Heroku::Helpers.home_directory, ".heroku", "config.json")
  end
end
