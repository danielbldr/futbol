require_relative "team_collection"
require_relative "game_team_collection"
require_relative "game_collection"

class StatTracker

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
    games_by_season = @game_collection.all.group_by{|game| game.season}         #games_by_season 1st occurance
    games_by_season.transform_values!{|games| games.length}
  end

  # This only requires game information.
  # It should probably move to game collection eventually.
  def average_goals_per_game
    all_goals = @game_collection.total_goals_per_game
    (all_goals.sum / all_goals.length.to_f).round(2)                            # create module with average method??

  end

  # This only requires game information.
  # It should probably move to game collection eventually.
  def average_goals_by_season
    games_by_season = @game_collection.all.group_by{|game| game.season}         #games_by_season 2nd occurance
    games_by_season.transform_values! do |games|
      all_goals = games.map{|game| game.away_goals + game.home_goals}
      (all_goals.sum/all_goals.length.to_f).round(2)                            #average_calculation
    end
  end

  # This only requires team information.
  # It should probably move to team collection eventually.
  def count_of_teams
    @team_collection.teams.length
  end

  # uses both team and game_team collections
  def best_offense
    games_by_team = @game_team_collection.all.group_by{|game| game.team_id}
    average_goals_by_team = games_by_team.transform_values do |games|
      ((games.map{|game| game.goals}.sum)/games.length.to_f)                      # average calculation
    end
    best_team = average_goals_by_team.key(average_goals_by_team.values.max)
    @team_collection.where_id(best_team)
  end

  # uses both team and game_team collections
  def worst_offense
    games_by_team = @game_team_collection.all.group_by{|game| game.team_id}
    team_ids = @team_collection.all.map{|team| team.team_id}  # This could be shifted to use the game_team_collection data, just use a #uniq at the end

    games_by_team = team_ids.reduce({}) do |games_by_team, team_id| # this snippet would better serve us in the game_team collection to be used by other methods
      games = @game_team_collection.all.find_all do |game_team|
         game_team.team_id == team_id
      end
      games_by_team[team_id] = games
      games_by_team
    end

    games_by_team = @game_team_collection.all.group_by{|game| game.team_id}

    average_goals_by_team = games_by_team.transform_values do |games|
      ((games.map{|game| game.goals}.sum)/games.length.to_f)                      # average calculation
    end
    worst_team = average_goals_by_team.key(average_goals_by_team.values.min)
    @team_collection.where_id(worst_team)
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
      goals.sum/goals.length.to_f                                                 # average calcultion
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

  #uses only game_collection
  def percentage_home_wins
    home_wins = @game_collection.games.find_all {|game| game.home_goals > game.away_goals}
    home_wins.length.to_f / (@game_collection.games.length.to_f).round(2)
  end

  #uses only game_collection
  def percentage_visitor_wins
    away_wins = @game_collection.games.find_all {|game| game.home_goals < game.away_goals}
    away_wins.length.to_f / (@game_collection.games.length.to_f).round(2)
  end

  #uses only game_collection
  def percentage_ties
    tied_games = @game_collection.games.find_all {|game| game.home_goals == game.away_goals}
    tied_games.lengtht.to_f / (@game_collection.games.length.to_f).round(2)
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
    shot_ratio_by_team = {}
    @game_team_collection.all.each do |game|
      if game.game_id.to_s.start_with?(season[0..3])
        if shot_ratio_by_team.has_key?(game.team_id)
          shot_ratio_by_team[game.team_id] << (game.goals.to_f/game.shots).round(2)
        else
          shot_ratio_by_team[game.team_id] = [(game.goals.to_f/game.shots).round(2)]
        end
      end
    end
    shot_ratio_by_team.transform_values! do |array|
      array.sum/array.length
    end
    @team_collection.where_id(shot_ratio_by_team.key(shot_ratio_by_team.values.min))
  end

  def most_accurate_team(season)
    shot_ratio_by_team = {}
    @game_team_collection.all.each do |game|
      if game.game_id.to_s.start_with?(season[0..3])
        if shot_ratio_by_team.has_key?(game.team_id)
          shot_ratio_by_team[game.team_id] << (game.goals.to_f/game.shots).round(2)
        else
          shot_ratio_by_team[game.team_id] = [(game.goals.to_f/game.shots).round(2)]
        end
      end
    end
    shot_ratio_by_team.transform_values! do |array|
      array.sum/array.length
    end
    @team_collection.where_id(shot_ratio_by_team.key(shot_ratio_by_team.values.max))
  end

  def best_fans
    home_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id) && game.home_or_away == 'home'
        accum[game.team_id] << game.result
      else
        accum[game.team_id] = [game.result] if game.home_or_away == 'home'
      end
      accum
    end
    away_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id)
        accum[game.team_id] << game.result && game.home_or_away == "away"
      else
        accum[game.team_id] = [game.result] if game.home_or_away == "away"
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
    home_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id) && game.home_or_away == 'home'
        accum[game.team_id] << game.result
      else
        accum[game.team_id] = [game.result] if game.home_or_away == 'home'
      end
      accum
    end
    away_hash = @game_team_collection.all.reduce({}) do |accum, game|
      if accum.has_key?(game.team_id)
        accum[game.team_id] << game.result && game.home_or_away == "away"
      else
        accum[game.team_id] = [game.result] if game.home_or_away == "away"
      end
      accum
    end
    home_hash.transform_values! { |stats| stats.count("WIN")/stats.length.to_f }
    away_hash.transform_values! { |stats| stats.count("WIN")/stats.length.to_f }
    home_minus_away = away_hash.merge(home_hash){|key, oldval, newval| newval - oldval}
    worst_team = home_minus_away.key(home_minus_away.values.min)
    @team_collection.where_id(worst_team)
  end

  def biggest_bust(season)
    regular = []
    post = []
    @game_collection.all.each do |game|
      if game.season == season && game.type == "Postseason"
        post << game.game_id
      elsif game.season == season && game.type == "Regular Season"
        regular << game.game_id
      end
    end
##
    game_teams_regular = @game_team_collection.all.find_all do |game_team|
      regular.include?(game_team.game_id)
    end
    game_teams_post = @game_team_collection.all.find_all do |game_team|
      post.include?(game_team.game_id)
    end

    game_teams_regular = @game_team_collection.all.reduce({}) do |accum, game_team|
      if regular.include?(game_team.game_id) && accum.has_key?(game_team.team_id)
        accum[game_team.team_id] << game_team.result
      elsif regular.include?(game_team.game_id)
        accum[game_team.team_id] = [game_team.result]
      end
      accum
    end

    game_teams_post = @game_team_collection.all.reduce({}) do |accum,game_team|
      if post.include?(game_team.game_id) && accum.has_key?(game_team.team_id)
        accum[game_team.team_id] << game_team.result
      elsif post.include?(game_team.game_id)
        accum[game_team.team_id] = [game_team.result]
      end
      accum
    end

    game_teams_regular.transform_values! { |result| result.count("WIN")/result.length.to_f }
    game_teams_post.transform_values! { |result| result.count("WIN")/result.length.to_f }
    post_minus_regular = game_teams_regular.merge(game_teams_post){|key, oldval, newval| newval - oldval}
    worst_team = post_minus_regular.key(post_minus_regular.values.min)
    @team_collection.where_id(worst_team)
  end

  def biggest_surprise(season)
    regular = []
    post = []
    @game_collection.all.each do |game|
      if game.season == season && game.type == "Postseason"
        post << game.game_id
      elsif game.season == season && game.type == "Regular Season"
        regular << game.game_id
      end
    end

    game_teams_regular = @game_team_collection.all.find_all do |game_team|
      regular.include?(game_team.game_id)
    end
    game_teams_post = @game_team_collection.all.find_all do |game_team|
      post.include?(game_team.game_id)
    end

    game_teams_regular = @game_team_collection.all.reduce({}) do |accum, game_team|
      if regular.include?(game_team.game_id) && accum.has_key?(game_team.team_id)
        accum[game_team.team_id] << game_team.result
      elsif regular.include?(game_team.game_id)
        accum[game_team.team_id] = [game_team.result]
      end
      accum
    end

    game_teams_post = @game_team_collection.all.reduce({}) do |accum,game_team|
      if post.include?(game_team.game_id) && accum.has_key?(game_team.team_id)
        accum[game_team.team_id] << game_team.result
      elsif post.include?(game_team.game_id)
        accum[game_team.team_id] = [game_team.result]
      end
      accum
    end

    game_teams_regular.transform_values! { |result| result.count("WIN")/result.length.to_f }
    game_teams_post.transform_values! { |result| result.count("WIN")/result.length.to_f }
    post_minus_regular = game_teams_regular.merge(game_teams_post){|key, oldval, newval| newval - oldval}
    best_team = post_minus_regular.key(post_minus_regular.values.max)
    @team_collection.where_id(best_team)
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
    home_team_goals = @team_collection.all.reduce({}) do |hash, team|
      hash[team.team_id] = []
      hash
    end

    @game_collection.all.each do |game|
      home_team_goals[game.home_team_id] << game.home_goals
    end

    average_home_goals = home_team_goals.transform_values do |goals|
      (goals.sum/goals.length.to_f) if goals != []# average calculation
    end

    highest_average = average_home_goals.values.max

    best_team = average_home_goals.key(highest_average)

    @team_collection.all.find do |team| # This snippet should move to team_collection as a #where(:key, value), ie where(team_id, 6)
      team.team_id == best_team
    end.team_name
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
end
