require 'json'
require 'set'
require 'date'

class ServiceManager

  # config files are read from a given path (defaults to config/),
  # processed and put into hashes
  def initialize(path = nil)
    path ||= "config/"
    path.concat '/' unless path.end_with? '/'
    begin
      @holidays = read_holidays "#{path}holidays.json"
      @app_config = read_app_config "#{path}apps.conf"
      @market_app_regexes = read_market_app_regexes "#{path}markets.conf"
    rescue Exception => e
      raise e
    end
    @market_apps = market_apps(@market_app_regexes, @app_config.keys)
  end

  # Returns a set of apps that are supposed to be running on a given date
  # No markets are open on weekends, market specific holidays are checked
  def apps_for_day(date)
    res = Set.new []
    unless date.saturday? or date.sunday?
      @market_apps.each do |market, apps|
        res = res + apps unless @holidays[date] and @holidays[date].include? market
      end
    end
    res
  end

  # Returns a hash of apps to be started and stopped for a week from the given date (inclusive)
  # Apps running on the day BEFORE the given date ARE taken into account
  # a list of app names can optionally be specified to filter the result
  def commands_for_week(date, filter_apps = nil)
    res = {}
    yesterday_apps = apps_for_day(date.prev_day)
    today = date
    7.times do
      todays_apps = apps_for_day(today)
      stopping_apps = yesterday_apps - todays_apps
      starting_apps = todays_apps - yesterday_apps
      unless filter_apps.nil?
        stopping_apps = stopping_apps & filter_apps
        starting_apps = starting_apps & filter_apps
      end
      res.merge! "#{today.to_s}" => {stopping_apps: stopping_apps, starting_apps: starting_apps}
      yesterday_apps = todays_apps
      today = today.next_day
    end
    res
  end

  # print_ methods

  def print_apps_for_day(date)
    apps_for_day(date).each do |app|
      puts app
    end
  end

  def print_commands_for_week(date, filter_apps = nil)
    commands_for_week(date, filter_apps).each do |day, apps|
      apps[:starting_apps].each do |app|
        puts "#{day.to_s} #{@app_config[app][:command]} start"
      end
      apps[:stopping_apps].each do |app|
        puts "#{day.to_s} #{@app_config[app][:command]} stop"
      end
    end
  end

  private

  # regex matching is expensive, lets do this once and cache the result
  # returns a hash of markets, mapping to apps
  def market_apps(market_app_regexes, apps)
    res = {}
    market_app_regexes.each do |market, regexes|
      res[market] = Set.new if res[market].nil?
      regexes.each do |regex|
        apps.each do |app|
          res[market].add app if app =~ /#{regex}/
        end
      end
    end
    res
  end

  # Reads market specific holidays from a JSON file as per specs
  # MULTIPLE entries per market
  # returns a hash
  def read_holidays(path_to_file)
    holidays = {}
    hash = JSON.parse File.read(path_to_file)
    hash.each do |entry|
      date = Date.parse(entry['date'])
      market = entry['market']
      holidays[date] = Set.new if holidays[date].nil?
      holidays[date].add market
    end
    holidays
  end

  # Reads app config (host, app name and command) from a text file as per specs
  # ONE line per host
  # returns a hash
  def read_app_config(path_to_file)
    app_config = {}
    File.open(path_to_file).readlines.each do |line|
      line.strip!
      unless line.start_with? '#' or line.empty?
        splitted = line.split(':')
        next unless splitted.size == 3
        app_config.merge! "#{splitted[1]}" => {host: splitted[0], command: splitted[2]}
      end
    end
    app_config
  end

  # Reads market app regexes from a text file as per specs
  # MULTIPLE lines per market
  # returns a hash
  def read_market_app_regexes(path_to_file)
    market_app_regexes = {}
    File.open(path_to_file).readlines.each do |line|
      line.strip!
      unless line.start_with? '#' or line.empty?
        splitted = line.split(':')
        next unless splitted.size == 2
        market = splitted[0]
        app = splitted[1]
        market_app_regexes[market] = Set.new if market_app_regexes[market].nil?
        market_app_regexes[market].add app
      end
    end
    market_app_regexes
  end

end
