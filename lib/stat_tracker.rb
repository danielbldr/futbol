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
  end
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
      average = total_goals_per_game.sum / total_goals_per_game.length.to_f # create module with average method??
      goals_by_season[season] = average.round(2)
      goals_by_season
    end
  end

  # This only requires team information.
  # It should probably move to team collection eventually.
  def count_of_teams
    @team_collection.teams.length
  end

  # uses both team and game_team info, needs to live in stat_tracker.
  def best_offense
    team_ids = @team_collection.all.map{|team| team.team_id}  # This could be shifted to use the game_team_collection data, just use a #uniq at the end

    games_by_team = team_ids.reduce({}) do |games_by_team, team_id| # this snippet would better serve us in the game_team collection to be used by other methods
      games = @game_team_collection.all.find_all do |game_team|
         game_team.team_id == team_id
      end
      games_by_team[team_id] = games
      games_by_team
    end

    average_goals_by_team = games_by_team.transform_values do |games|
      ((games.map{|game| game.goals}.sum)/games.length.to_f)  # average calculation
    end

    best_average = average_goals_by_team.values.max

    best_team = average_goals_by_team.key(best_average) # checks for first occurance of best average, need to gain clarification from teachers!!

    @team_collection.all.find do |team| # This snippet should move to team_collection as a #where(:key, value), ie where(team_id, 6)
      team.team_id == best_team
    end.team_name
  end

  def worst_offense
    team_ids = @team_collection.all.map{|team| team.team_id}  # This could be shifted to use the game_team_collection data, just use a #uniq at the end

    games_by_team = team_ids.reduce({}) do |games_by_team, team_id| # this snippet would better serve us in the game_team collection to be used by other methods
      games = @game_team_collection.all.find_all do |game_team|
         game_team.team_id == team_id
      end
      games_by_team[team_id] = games
      games_by_team
    end

    average_goals_by_team = games_by_team.transform_values do |games|
      ((games.map{|game| game.goals}.sum)/games.length.to_f)  # average calculation
    end

    worst_average = average_goals_by_team.values.min

    worst_team = average_goals_by_team.key(worst_average) # checks for first occurance of best average, need to gain clarification from teachers!!

    @team_collection.all.find do |team| # This snippet should move to team_collection as a #where(:key, value), ie where(team_id, 6)
      team.team_id == worst_team
    end.team_name
  end
end
