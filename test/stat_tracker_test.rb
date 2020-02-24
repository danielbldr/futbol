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
  end
end
