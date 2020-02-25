require_relative 'game'
require 'csv'

class GameCollection
  attr_reader :games, :csv_file_path

  def initialize(csv_file_path)
    @games = []
    @csv_file_path = csv_file_path
  end

  def instantiate_game(info)
    Game.new(info)
  end

  def collect_game(game)
    @games << game
  end

  def create_game_collection
    CSV.foreach(@csv_file_path, headers: true, header_converters: :symbol) do |row|
      collect_game(instantiate_game(row))
    end
  end

  def total_goals_per_game
    @games.map {|game| game.away_goals + game.home_goals}
  end

  def all
    @games
  end

  def array_by_key(key)
    @games.map{|game| game.send "#{key}" }.uniq  ## can probably put this in a module passing class, collection, and key as arguments
  end

  def games_by_season
    all.group_by{|game| game.season}
  end

  def count_of_games_by_season
    games_by_season.transform_values!{|games| games.length}
  end
end
