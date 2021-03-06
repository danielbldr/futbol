require_relative "team_collection"
require_relative "game_team_collection"
require_relative "game_collection"
require_relative "calculable"

class StatTracker
  include Calculable

  def self.from_csv(csv_file_paths)
    self.new(csv_file_paths)
  end

  attr_reader :team_collection, :game_collection, :game_team_collection
  def initialize(files)
    @team_collection = TeamCollection.new(files[:teams])
    @game_collection = GameCollection.new(files[:games])
    @game_team_collection = GameTeamCollection.new(files[:game_teams])
    @team_collection.create_team_collection
    @game_collection.create_game_collection
    @game_team_collection.create_game_team_collection
  end

  def highest_total_score
    @game_collection.total_goals_per_game(@game_collection.all).max
  end

  def lowest_total_score
    @game_collection.total_goals_per_game(@game_collection.all).min
  end

  def biggest_blowout
    @game_collection.games.map {|game| (game.away_goals - game.home_goals).abs}.max
  end

  def count_of_games_by_season
    @game_collection.count_of_games_by_season
  end

  def average_goals_per_game
    average(@game_collection.total_goals_per_game(@game_collection.all))
  end

  def average_goals_by_season
    @game_collection.average_goals_by_season
  end

  def count_of_teams
    @team_collection.teams.length
  end

  def best_offense
    @team_collection.where_id(@game_team_collection.is_best_offense(true))
  end

  def worst_offense
    @team_collection.where_id(@game_team_collection.is_best_offense(false))
  end

  #uses both team and game collections.
  def best_defense
    goals_against_by_team = {}
    @team_collection.array_by_key(:team_id).each do |team_id|
      goals_against_by_team[team_id] = []
    end
    @game_collection.all.each do |game|
      goals_against_by_team[game.home_team_id] << game.away_goals
      goals_against_by_team[game.away_team_id] << game.home_goals
    end
    goals_against_by_team.transform_values! do |goals|
      average(goals)
    end
    best_defense = goals_against_by_team.key(goals_against_by_team.values.min)
    @team_collection.where_id(best_defense)
  end

  # uses both team and game collections.
  # needs refactoring
  def worst_defense
    goals_against_team = @team_collection.all.reduce({}) do |hash, team|
      hash[team.team_id] = []
      hash
    end

    @game_collection.all.each do |game|
      goals_against_team[game.home_team_id] << game.away_goals
      goals_against_team[game.away_team_id] << game.home_goals
    end

    average_goals_against_team = goals_against_team.transform_values do |goals|
      (goals.sum/goals.length.to_f)                                               # average calculation
    end

    worst_average = average_goals_against_team.values.max

    worst_team = average_goals_against_team.key(worst_average)

    @team_collection.where_id(worst_team)
  end

  def percentage_home_wins
    @game_collection.percentage_home_wins
  end

  def percentage_visitor_wins
    @game_collection.percentage_visitor_wins
  end

  def percentage_ties
    @game_collection.percentage_ties
  end

  def lowest_scoring_home_team
    @team_collection.where_id(@game_collection.lowest_scoring_home_team_id)
  end

  #uses game and game_team collections.
  def winningest_coach(for_season) # the game_ids can tell you what season there from. first 4 numbers of id will match the first 4 from season.
    game_teams = @game_team_collection.all.find_all do |game|
       game.game_id.to_s[0,4] == for_season[0,4]
    end
    game_team_by_coach = game_teams.group_by { |game| game.head_coach }
    game_team_by_coach.each do |key, value|
       percent = value.count{|game| game.result == "WIN"}/value.length.to_f
       game_team_by_coach[key] = percent
    end
    game_team_by_coach.key(game_team_by_coach.values.max)
  end

  #uses game and game_team_collection
  def worst_coach(for_season)
    game_teams = @game_team_collection.all.find_all do |game|
       game.game_id.to_s[0,4] == for_season[0,4]
    end
    game_team_by_coach = game_teams.group_by { |game| game.head_coach }
    game_team_by_coach.each do |key, value|
       percent = value.count{|game| game.result == "WIN"}/value.length.to_f
       game_team_by_coach[key] = percent
     end
    game_team_by_coach.key(game_team_by_coach.values.min)
  end

  def most_tackles(season)
    tackles_by_team = {} #can add lines 190 - 199 as method in GameTeamCollection
    @game_team_collection.all.each do |game|
      if game.game_id.to_s.start_with?(season[0..3])
        if tackles_by_team.has_key?(game.team_id)
          tackles_by_team[game.team_id] += game.tackles
        else
          tackles_by_team[game.team_id] = game.tackles
        end
      end
    end
    @team_collection.where_id(tackles_by_team.key(tackles_by_team.values.max))
  end

  def fewest_tackles(season)
    tackles_by_team = {} #Lines 204 - 213 are duplicate from most_tackles
    @game_team_collection.all.each do |game|
      if game.game_id.to_s.start_with?(season[0..3])
        if tackles_by_team.has_key?(game.team_id)
          tackles_by_team[game.team_id] += game.tackles
        else
          tackles_by_team[game.team_id] = game.tackles
        end
      end
    end
    @team_collection.where_id(tackles_by_team.key(tackles_by_team.values.min))
  end

  def least_accurate_team(season) #maybe refactor to do shots/attempts.
    games_of_season = @game_team_collection.all.find_all do |game_team|
      game_team.game_id.to_s[0,4] == season[0,4]
    end

    goals_and_shots = games_of_season.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id)
        accum[game.team_id][:shots] += game.shots
        accum[game.team_id][:goals] += game.goals
      else
        accum[game.team_id] = {shots: game.shots, goals: game.goals}
      end
      accum
    end

    goals_and_shots.transform_values! do |game|
      game[:goals]/game[:shots].to_f
    end
    @team_collection.where_id(goals_and_shots.key(goals_and_shots.values.min))
  end

  def most_accurate_team(season)
    games_of_season = @game_team_collection.all.find_all do |game_team|
      game_team.game_id.to_s[0,4] == season[0,4]
    end

    goals_and_shots = games_of_season.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id)
        accum[game.team_id][:shots] += game.shots
        accum[game.team_id][:goals] += game.goals
      else
        accum[game.team_id] = {shots: game.shots, goals: game.goals}
      end
      accum
    end

    goals_and_shots.transform_values! do |game|
      game[:goals]/game[:shots].to_f
    end
    @team_collection.where_id(goals_and_shots.key(goals_and_shots.values.max))
  end

# can try to put both best/worstfans in game_team_collection
  def best_fans
    home_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id) && game.home_or_away == 'home'
        accum[game.team_id] << game.result
      elsif game.home_or_away == 'home'
        accum[game.team_id] = [game.result]
      end
      accum
    end
    away_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id) && game.home_or_away == "away"
        accum[game.team_id] << game.result
      elsif game.home_or_away == "away"
        accum[game.team_id] = [game.result]
      end
      accum
    end
    home_hash.transform_values! { |stats| stats.count("WIN")/stats.length.to_f }
    away_hash.transform_values! { |stats| stats.count("WIN")/stats.length.to_f }
    home_minus_away = away_hash.merge(home_hash){|key, oldval, newval| newval - oldval}
    best_team = home_minus_away.key(home_minus_away.values.max)
    @team_collection.where_id(best_team)
  end

  def worst_fans
    team_id = []
    games_by_teams = @game_team_collection.all.group_by do |game|
      game.team_id
    end
    games_by_teams.each do |team, games|
      away_wins = games.count{|game| game.home_or_away == "away" && game.result == "WIN"}
      home_wins = games.count{|game| game.home_or_away == "home" && game.result == "WIN"}
      if away_wins > home_wins
        team_id << team
      end
    end
    team_id.map{|id| @team_collection.where_id(id)}
  end

  def biggest_bust(season)
    ##come back to this later
  end

  def biggest_surprise(season)
    ##come back to this later
  end

  def highest_scoring_visitor
    away_team_goals = @team_collection.all.reduce({}) do |hash, team|
      hash[team.team_id] = []
      hash
    end

    @game_collection.all.each do |game|
      away_team_goals[game.away_team_id] << game.away_goals
    end

    average_away_goals = away_team_goals.transform_values do |goals|
      (goals.sum/goals.length.to_f) if goals != []# average calculation
    end

    highest_average = average_away_goals.values.max

    best_team = average_away_goals.key(highest_average)

    @team_collection.all.find do |team| # This snippet should move to team_collection as a #where(:key, value), ie where(team_id, 6)
      team.team_id == best_team
    end.team_name
  end

  def highest_scoring_home_team
    home_team_goals = @game_collection.all.reduce({}) do |goals_by_team, game|
      if goals_by_team.has_key?(game.home_team_id)
        goals_by_team[game.home_team_id] << game.home_goals
      else
        goals_by_team[game.home_team_id] = [game.home_goals]
      end
      goals_by_team
    end

    average_home_goals = home_team_goals.transform_values do |goals|
      goals.sum/goals.length.to_f
    end

    best_team = average_home_goals.key(average_home_goals.values.max)

    @team_collection.where_id(best_team)
  end

  def lowest_scoring_visitor
    away_team_goals = @team_collection.all.reduce({}) do |hash, team|
      hash[team.team_id] = []
      hash
    end

    @game_collection.all.each do |game|
      away_team_goals[game.away_team_id] << game.away_goals
    end

    average_away_goals = away_team_goals.transform_values do |goals|
      (goals.sum/goals.length.to_f) if goals != []# average calculation
    end

    lowest_average = average_away_goals.values.min

    worst_team = average_away_goals.key(lowest_average)

    @team_collection.all.find do |team| # This snippet should move to team_collection as a #where(:key, value), ie where(team_id, 6)
      team.team_id == worst_team
    end.team_name
  end

 def winningest_team
  gameteamhash = @game_team_collection.all.group_by {|game| game.team_id}
  gameteamhash.transform_values! do |game|
    (game.count {|game| game.result == "WIN"}) / game.length.to_f
  end
  best_team = gameteamhash.key(gameteamhash.values.max)
  @team_collection.where_id(best_team)
 end

end
