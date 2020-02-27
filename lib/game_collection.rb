require_relative 'game'
require_relative 'calculable'
require 'csv'

class GameCollection
  include Calculable
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

  def total_goals_per_game(array)
    array.map {|game| game.away_goals + game.home_goals}
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

  def average_goals_by_season
    games_by_season.transform_values! do |games|
      average(total_goals_per_game(games))
    end
  end

  def percentage_home_wins
    home_wins = all.find_all {|game| game.home_goals > game.away_goals}
    percentage(home_wins, all)
  end

  def percentage_visitor_wins
    visitor_wins = all.find_all {|game| game.home_goals < game.away_goals}
    percentage(visitor_wins, all)
  end

  def percentage_ties
    ties = all.find_all {|game| game.home_goals == game.away_goals}
    percentage(ties, all)
  end

  def lowest_scoring_home_team_id
    home_team_goals = all.reduce({}) do |goals_by_team, game|
      if goals_by_team.has_key?(game.home_team_id)
        goals_by_team[game.home_team_id] << game.home_goals
      else
        goals_by_team[game.home_team_id] = [game.home_goals]
      end
      goals_by_team
    end
    average_home_goals = home_team_goals.transform_values do |goals|
      average(goals)
    end
    average_home_goals.key(average_home_goals.values.min)
  end
end
