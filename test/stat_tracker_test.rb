require './test/test_helper'
require "minitest/autorun"
require "minitest/pride"
require 'mocha/minitest'
require "./lib/stat_tracker"

class StatTrackerTest < Minitest::Test
  def setup
    @info = {
            games: "./test/fixtures/games_truncated.csv",
            teams: "./test/fixtures/teams_truncated.csv",
            game_teams: "./test/fixtures/game_teams_truncated.csv"
            }

    @info_for_averages = {
                          games: "./test/fixtures/games_average_truncated.csv",
                          teams: "./test/fixtures/teams_truncated.csv",
                          game_teams: "./test/fixtures/game_teams_average_truncated.csv"
                          }

    @stat_tracker = StatTracker.from_csv(@info)
    @stat_tracker_average = StatTracker.from_csv(@info_for_averages)
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_has_attributes
    assert_instance_of TeamCollection, @stat_tracker.team_collection
    assert_instance_of GameCollection, @stat_tracker.game_collection
    assert_instance_of GameTeamCollection, @stat_tracker.game_team_collection
  end

  def test_it_can_calculate_highest_total_score
    assert_equal 6, @stat_tracker.highest_total_score
  end

  def test_it_can_calculate_lowest_total_score
    assert_equal 3, @stat_tracker.lowest_total_score
  end

  def test_it_can_return_biggest_blowout
    assert_equal 2, @stat_tracker.biggest_blowout
  end

  def test_it_can_count_the_games_by_season
    expected = {"20122013"=>7, "20132014"=>3}

    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_calculate_average_goals_per_game
    assert_equal (4.50), @stat_tracker.average_goals_per_game
  end

  def test_it_can_show_average_goals_by_season
    expected = {"20122013"=>4.71, "20132014"=>4.00}
    assert_equal expected, @stat_tracker.average_goals_by_season
  end

  def test_it_can_get_home_wins_percentage
    assert_equal 0.6, @stat_tracker.percentage_home_wins
  end

  def test_it_can_get_away_win_percentages
    assert_equal 0.3, @stat_tracker.percentage_visitor_wins
  end

  def test_it_can_get_tied_percentage ## refactor with new data pool to grab real percentage instead of stub
    @stat_tracker.stubs(:percentage_ties).returns(0.10)

    assert 0.10, @stat_tracker.percentage_ties
  end

  def test_it_can_count_number_of_teams
    assert_equal 9, @stat_tracker.count_of_teams
  end

  def test_it_can_find_the_best_offense
    assert_equal "Real Salt Lake", @stat_tracker_average.best_offense
  end

  def test_it_can_find_the_worst_offense
    assert_equal "Orlando Pride", @stat_tracker_average.worst_offense
  end

  def test_it_can_find_the_best_defense
    assert_equal "Real Salt Lake", @stat_tracker_average.best_defense
  end

  def test_it_can_find_the_worst_defense
    assert_equal "Chicago Fire", @stat_tracker_average.worst_defense
  end

  def test_it_can_find_the_winningest_coach_by_season #I need a better data pool for this
    assert_equal "Bruce Boudreau", @stat_tracker_average.winningest_coach("20122013")
  end

  def test_it_can_find_the_worst_coach_by_season

    game_team_1_info =  {
                        game_id: "2012030221",team_id: "3",
                        hoa: "away",result: "LOSS",settled_in: "OT",
                        head_coach: "John Tortorella",goals: "2",shots: "8",
                        tackles: "44",pim: "8",powerplayopportunities: "3",
                        powerplaygoals: "0",faceoffwinpercentage: "44.8",
                        giveaways: "17",takeaways: "7"
                        }
    game_team_2_info = {
                        game_id: "2012030221",team_id: "6",
                        hoa: "away",result: "WIN",settled_in: "OT",
                        head_coach: "John Tortorella",goals: "2",shots: "8",
                        tackles: "44",pim: "8",powerplayopportunities: "3",
                        powerplaygoals: "0",faceoffwinpercentage: "44.8",
                        giveaways: "17",takeaways: "7"
                        }
    game_team_3_info = {
                        game_id: "2012030222",team_id: "6",
                        hoa: "away",result: "WIN",settled_in: "OT",
                        head_coach: "John Tortorella",goals: "2",shots: "8",
                        tackles: "44",pim: "8",powerplayopportunities: "3",
                        powerplaygoals: "0",faceoffwinpercentage: "44.8",
                        giveaways: "17",takeaways: "7"
                        }
    game_team_4_info = {
                        game_id: "2012030222",team_id: "3",
                        hoa: "away",result: "LOSS",settled_in: "OT",
                        head_coach: "John Tortorella",goals: "2",shots: "8",
                        tackles: "44",pim: "8",powerplayopportunities: "3",
                        powerplaygoals: "0",faceoffwinpercentage: "44.8",
                        giveaways: "17",takeaways: "7"
                        }

    game_team1_1 = GameTeam.new(game_team_1_info)
    game_team1_2 = GameTeam.new(game_team_2_info)
    game_team2_1 = GameTeam.new(game_team_3_info)
    game_team2_2 = GameTeam.new(game_team_4_info)

    @stat_tracker.game_team_collection.stubs(:all).returns([game_team1_1, game_team1_2,
                                                         game_team2_1, game_team2_2])

    assert_equal "John Tortorella", @stat_tracker.worst_coach("20122013")
  end

  def test_it_can_return_team_with_most_tackles
    assert_equal "FC Dallas", @stat_tracker_average.most_tackles("20122013")
    assert_equal "Chicago Fire", @stat_tracker_average.most_tackles("20132014")
  end

  def test_it_can_return_team_with_fewest_tackles
    assert_equal "Sky Blue FC", @stat_tracker_average.fewest_tackles("20122013")
    assert_equal "Montreal Impact", @stat_tracker_average.fewest_tackles("20132014")
  end

  def test_it_can_return_least_accurate_team
    assert_equal "Orlando Pride", @stat_tracker_average.least_accurate_team("20122013")
    assert_equal "LA Galaxy", @stat_tracker_average.least_accurate_team("20132014")
  end

  def test_it_can_find_the_most_accurate_team
    assert_equal "Real Salt Lake", @stat_tracker_average.most_accurate_team("20122013")
  end

  def test_it_can_return_best_fan
    assert_equal "Philadelphia Union", @stat_tracker_average.best_fans
  end

  def test_it_can_return_worst_fan
    assert_equal "FC Dallas", @stat_tracker_average.worst_fans
  end

  def test_it_can_find_the_biggest_bust
    game_1_info = {game_id: "2012030221", season: "20122013", type: "Regular Season"}
    game_2_info = {game_id: "2012030222", season: "20122013", type: "Regular Season"}
    game_3_info = {game_id: "2012030223", season: "20122013", type: "Regular Season"}
    game_4_info = {game_id: "2012030224", season: "20122013", type: "Postseason"}
    game_5_info = {game_id: "2012030225", season: "20122013", type: "Postseason"}
    game_6_info = {game_id: "2012030226", season: "20122013", type: "Postseason"}

    game_team_1_1_info =  {game_id: "2012030221",team_id: "3",result: "WIN"}
    game_team_1_2_info =  {game_id: "2012030221",team_id: "6",result: "LOSS"}
    game_team_2_1_info =  {game_id: "2012030222",team_id: "3",result: "WIN"}
    game_team_2_2_info =  {game_id: "2012030222",team_id: "6",result: "LOSS"}
    game_team_3_1_info =  {game_id: "2012030223",team_id: "3",result: "LOSS"}
    game_team_3_2_info =  {game_id: "2012030223",team_id: "6",result: "WIN"}
    game_team_4_1_info =  {game_id: "2012030224",team_id: "3",result: "LOSS"}
    game_team_4_2_info =  {game_id: "2012030224",team_id: "6",result: "WIN"}
    game_team_5_1_info =  {game_id: "2012030225",team_id: "3",result: "LOSS"}
    game_team_5_2_info =  {game_id: "2012030225",team_id: "6",result: "WIN"}
    game_team_6_1_info =  {game_id: "2012030226",team_id: "3",result: "WIN"}
    game_team_6_2_info =  {game_id: "2012030226",team_id: "6",result: "LOSS"}

    game1 = Game.new(game_1_info)
    game2 = Game.new(game_2_info)
    game3 = Game.new(game_3_info)
    game4 = Game.new(game_4_info)
    game5 = Game.new(game_5_info)
    game6 = Game.new(game_6_info)

    game_team1 = GameTeam.new(game_team_1_1_info)
    game_team2 = GameTeam.new(game_team_1_2_info)
    game_team3 = GameTeam.new(game_team_2_1_info)
    game_team4 = GameTeam.new(game_team_2_2_info)
    game_team5 = GameTeam.new(game_team_3_1_info)
    game_team6 = GameTeam.new(game_team_3_2_info)
    game_team7 = GameTeam.new(game_team_4_1_info)
    game_team8 = GameTeam.new(game_team_4_2_info)
    game_team9 = GameTeam.new(game_team_5_1_info)
    game_team10 = GameTeam.new(game_team_5_2_info)
    game_team11 = GameTeam.new(game_team_6_1_info)
    game_team12 = GameTeam.new(game_team_6_2_info)

    @stat_tracker.game_collection.stubs(:all).returns([game1, game2, game3, game4, game5, game6])
    @stat_tracker.game_team_collection.stubs(:all).returns([
                                                            game_team1,
                                                            game_team2,
                                                            game_team3,
                                                            game_team4,
                                                            game_team5,
                                                            game_team6,
                                                            game_team7,
                                                            game_team8,
                                                            game_team9,
                                                            game_team10,
                                                            game_team11,
                                                            game_team12
                                                            ])
    assert_equal "Houston Dynamo", @stat_tracker.biggest_bust("20122013")
  end

  def test_it_can_find_the_biggest_suprise
    game_1_info = {game_id: "2012030221", season: "20122013", type: "Regular Season"}
    game_2_info = {game_id: "2012030222", season: "20122013", type: "Regular Season"}
    game_3_info = {game_id: "2012030223", season: "20122013", type: "Regular Season"}
    game_4_info = {game_id: "2012030224", season: "20122013", type: "Postseason"}
    game_5_info = {game_id: "2012030225", season: "20122013", type: "Postseason"}
    game_6_info = {game_id: "2012030226", season: "20122013", type: "Postseason"}

    game_team_1_1_info =  {game_id: "2012030221",team_id: "3",result: "WIN"}
    game_team_1_2_info =  {game_id: "2012030221",team_id: "6",result: "LOSS"}
    game_team_2_1_info =  {game_id: "2012030222",team_id: "3",result: "WIN"}
    game_team_2_2_info =  {game_id: "2012030222",team_id: "6",result: "LOSS"}
    game_team_3_1_info =  {game_id: "2012030223",team_id: "3",result: "LOSS"}
    game_team_3_2_info =  {game_id: "2012030223",team_id: "6",result: "WIN"}
    game_team_4_1_info =  {game_id: "2012030224",team_id: "3",result: "LOSS"}
    game_team_4_2_info =  {game_id: "2012030224",team_id: "6",result: "WIN"}
    game_team_5_1_info =  {game_id: "2012030225",team_id: "3",result: "LOSS"}
    game_team_5_2_info =  {game_id: "2012030225",team_id: "6",result: "WIN"}
    game_team_6_1_info =  {game_id: "2012030226",team_id: "3",result: "WIN"}
    game_team_6_2_info =  {game_id: "2012030226",team_id: "6",result: "LOSS"}

    game1 = Game.new(game_1_info)
    game2 = Game.new(game_2_info)
    game3 = Game.new(game_3_info)
    game4 = Game.new(game_4_info)
    game5 = Game.new(game_5_info)
    game6 = Game.new(game_6_info)

    game_team1 = GameTeam.new(game_team_1_1_info)
    game_team2 = GameTeam.new(game_team_1_2_info)
    game_team3 = GameTeam.new(game_team_2_1_info)
    game_team4 = GameTeam.new(game_team_2_2_info)
    game_team5 = GameTeam.new(game_team_3_1_info)
    game_team6 = GameTeam.new(game_team_3_2_info)
    game_team7 = GameTeam.new(game_team_4_1_info)
    game_team8 = GameTeam.new(game_team_4_2_info)
    game_team9 = GameTeam.new(game_team_5_1_info)
    game_team10 = GameTeam.new(game_team_5_2_info)
    game_team11 = GameTeam.new(game_team_6_1_info)
    game_team12 = GameTeam.new(game_team_6_2_info)

    @stat_tracker.game_collection.stubs(:all).returns([game1, game2, game3, game4, game5, game6])
    @stat_tracker.game_team_collection.stubs(:all).returns([
                                                            game_team1,
                                                            game_team2,
                                                            game_team3,
                                                            game_team4,
                                                            game_team5,
                                                            game_team6,
                                                            game_team7,
                                                            game_team8,
                                                            game_team9,
                                                            game_team10,
                                                            game_team11,
                                                            game_team12
                                                            ])
    assert_equal "FC Dallas", @stat_tracker.biggest_surprise("20122013")
  end
end
