require "./lib/team_collection"
require "./lib/game_team_collection"
require "./lib/game_collection"

class StatTracker

  def self.from_csv(csv_file_paths)
    self.new(csv_file_paths)
  end

  attr_reader :team_collection, :game_collection, :game_team_collection
  def initialize(files)
    @team_collection = TeamCollection.new(files[:team])
    @game_collection = GameCollection.new(files[:game])
    @game_team_collection = GameTeamCollection.new(files[:game_team])
    @team_collection.create_team_collection
    @game_collection.create_game_collection
    @game_team_collection.create_game_team_collection
  end

  def highest_total_score
    @game_collection.total_goals_per_game.max
  end

  def lowest_total_score
    @game_collection.total_goals_per_game.min
  end

  def biggest_blowout
    @game_collection.games.map {|game| (game.away_goals - game.home_goals).abs}.max

  # This only requires game information.
  # It should probably move to game collection eventually.
  def count_of_games_by_season
    seasons = @game_collection.games.map{|game| game.season }.uniq  #season needs helper method
    seasons.reduce({}) do |games_by_season, season|
      games_per_season = @game_collection.games.find_all do |game|  #games_per_season needs helper method
         season == game.season
      end.length
    games_by_season[season] = games_per_season
    games_by_season
    end
  end

  # Can and should implement daniels helper method for total_goals_per_game
  # This only requires game information.
  # It should probably move to game collection eventually.
  def average_goals_per_game
    total_goals_per_game = @game_collection.games.map do |game|
      game.home_goals + game.away_goals
    end
    average = total_goals_per_game.sum / total_goals_per_game.length.to_f  # create module with average method??
    average.round(2)
  end

  # This only requires game information.
  # It should probably move to game collection eventually.
  def average_goals_by_season
    seasons = @game_collection.games.map{|game| game.season }.uniq #season needs helper method
    seasons.reduce({}) do |goals_by_season, season|
      games_per_season = @game_collection.games.find_all do |game|  #games_per_season needs helper method
         season == game.season
      end
      total_goals_per_game = games_per_season.map do |game|  #very similar to total_goals_per_game in previus method
        game.home_goals + game.away_goals
      end
      average = total_goals_per_game.sum / total_goals_per_game.length.to_f
      goals_by_season[season] = average.round(2)
      goals_by_season
    end
  end
end
