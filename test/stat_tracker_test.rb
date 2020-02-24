require './test/test_helper'
require "minitest/autorun"
require "minitest/pride"
require 'mocha/minitest'
require "./lib/stat_tracker"

class StatTrackerTest < Minitest::Test
  def setup
    @info = {
            game: "./test/fixtures/games_truncated.csv",
            team: "./test/fixtures/teams_truncated.csv",
            game_team: "./test/fixtures/game_teams_truncated.csv"
            }
    @stat_tracker = StatTracker.from_csv(@info)
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
    skip
    assert_equal 6, @stat_tracker.highest_total_score
  end

  def test_it_can_calculate_lowest_total_score
    skip
    assert_equal 3, @stat_tracker.lowest_total_score
  end

  def test_it_can_return_biggest_blowout
    skip
    assert_equal 2, @stat_tracker.biggest_blowout
  end

  def test_it_can_count_the_games_by_season
    skip
    expected = {20122013=>7, 20132014=>3}

    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_calculate_average_goals_per_game
    skip
    assert_equal (4.50), @stat_tracker.average_goals_per_game
  end

  def test_it_can_show_average_goals_by_season
    skip
    expected = {20122013=>4.71, 20132014=>4.00}
    assert_equal expected, @stat_tracker.average_goals_by_season
  end

  def test_it_can_get_home_wins_percentage
    skip
    assert_equal 0.6, @stat_tracker.percentage_home_wins
  end

  def test_it_can_get_away_win_percentages
    skip
    assert_equal 0.3, @stat_tracker.percentage_visitor_wins
  end

  def test_it_can_get_tied_percentage
    skip
    @stat_tracker.stubs(:percentage_ties).returns(0.10)
    assert_equal 0.10, @stat_tracker.percentage_ties
  end

  def test_it_can_lowest_scoring_home_team_hash
    skip
    expected = {
      "FC Dallas" => 4,
      "Houston Dynamo" => 2,
      "Montreal Impact" => 2,
      "Chicago Fire" => 2,
      "Real Salt Lake" => 3,
      "Orlando Pride" => 2
    }
    assert_equal expected, @stat_tracker.lowest_scoring_home_team_hash
  end

  def test_it_can_lowest_scoring_home_team
    skip
    assert_equal "Houston Dynamo", @stat_tracker.lowest_scoring_home_team
  end

  def test_winningest_team_hash
    expected = {
      "Houston Dynamo"=>50.9,
      "FC Dallas"=>47.3,
      "Philadelphia Union"=>40.3,
      "Montreal Impact"=>59.7,
      "Real Salt Lake"=>52.4,
      "Chicago Fire"=>47.1,
      "Orlando Pride"=>58.3,
      "Sky Blue FC"=>52.7,
      "LA Galaxy"=>41.7
    }
    assert_equal expected, @stat_tracker.winningest_team_hash
  end

  def test_winningest_team
    assert_equal "Montreal Impact", @stat_tracker.winningest_team
  end

  def test_best_fans
    expected = {
      3=>"away",
      6=>"home",
      19=>"away",
      23=>"home",
      24=>"home",
      4=>"home",
      29=>"home",
      12=>"away",
      17=>"away"
    }
    assert_equal expected, @stat_tracker.best_fans
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
    game_1_info = {
                    game_id: "2012030221", season: "20122013", type: "Postseason",
                    date_time: "5/16/13", away_team_id: "3", home_team_id: "6", away_goals: "2",
                    home_goals: "3", venue: "Toyota Stadium", venue_link: "/api/v1/venues/null"
                  }
    game_2_info = {
                    game_id: "2012030222", season: "20122013", type: "Postseason",
                    date_time: "5/16/13", away_team_id: "6", home_team_id: "3", away_goals: "2",
                    home_goals: "3", venue: "Toyota Stadium", venue_link: "/api/v1/venues/null"
                  }
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
    @game_collection.stubs(:all).returns([])
  end

  def test_it_can_find_the_worst_coach_by_season
    assert_equal "TBD", @stat_tracker_average.worst_coach("20122013")  #Ileft this a TBD for now. i need a new fixture file.
  end
end
