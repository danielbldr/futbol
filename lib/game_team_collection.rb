require_relative "game_team"
require "csv"
class GameTeamCollection

  attr_reader :games_by_teams, :csv_file_path
  def initialize(csv_file_path)
    @games_by_teams = []
    @csv_file_path = csv_file_path
  end

  def instantiate_game_team(info)
    GameTeam.new(info)
  end

  def collect_game_team(game_team_object)
    @games_by_teams << game_team_object
  end

  def create_game_team_collection
    CSV.foreach(@csv_file_path, headers:true, header_converters: :symbol) do |row|
      collect_game_team(instantiate_game_team(row))
    end
  end

  def all
    @games_by_teams
  end

  def array_by_key(key)
    @games_by_teams.map{|game| game.send "#{key}" }.uniq
  end

  def where(key, value)
    @games_by_teams.find_all{|game| game.send("#{key}") == value}
  end
end
