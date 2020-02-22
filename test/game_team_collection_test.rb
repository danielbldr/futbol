require './test/test_helper'
require "minitest/autorun"
require "minitest/pride"
require "./lib/game_team_collection"

class GameTeamCollectionTest < Minitest::Test

  def setup
    @file_path = "./test/fixtures/game_teams_truncated.csv"
    @game_team_collection = GameTeamCollection.new(@file_path)
  end

  def test_it_exists
    assert_instance_of GameTeamCollection, @game_team_collection
  end

  def test_it_has_attributes
    assert_equal [], @game_team_collection.games_by_teams
    assert_equal "./test/fixtures/game_teams_truncated.csv", @game_team_collection.csv_file_path
  end

  def test_it_can_instantiate_a_game_team_object
    info = {game_id: "2012030221",team_id: "3",
            hoa: "away",result: "LOSS",settled_in: "OT",
            head_coach: "John Tortorella",goals: "2",shots: "8",
            tackles: "44",pim: "8",powerplayopportunities: "3",
            powerplaygoals: "0",faceoffwinpercentage: "44.8",
            giveaways: "17",takeaways: "7"}
    game_team = @game_team_collection.instantiate_game_team(info)

    assert_instance_of GameTeam, game_team
    assert_equal 2012030221, game_team.game_id
    assert_equal 3, game_team.team_id
    assert_equal "away", game_team.home_or_away
    assert_equal "LOSS", game_team.result
    assert_equal "OT", game_team.settled_in
    assert_equal "John Tortorella", game_team.head_coach
    assert_equal 2, game_team.goals
    assert_equal 8, game_team.shots
    assert_equal 44, game_team.tackles
    assert_equal 8, game_team.pim
    assert_equal 3, game_team.power_play_opportunities
    assert_equal 0, game_team.power_play_goals
    assert_equal 44.8, game_team.face_of_win_percentage
    assert_equal 17, game_team.giveaways
    assert_equal 7, game_team.takeaways
  end

  def test_it_can_collect_a_game_team_object
    info = {game_id: "2012030221",team_id: "3",
            hoa: "away",result: "LOSS",settled_in: "OT",
            head_coach: "John Tortorella",goals: "2",shots: "8",
            tackles: "44",pim: "8",powerplayopportunities: "3",
            powerplaygoals: "0",faceoffwinpercentage: "44.8",
            giveaways: "17",takeaways: "7"}
    game_team = @game_team_collection.instantiate_game_team(info)
    @game_team_collection.collect_game_team(game_team)

    assert_equal [game_team], @game_team_collection.games_by_teams
  end

  def test_it_can_create_collection_of_game_team_objects_from_csv
    @game_team_collection.create_game_team_collection

    assert_instance_of GameTeam, @game_team_collection.games_by_teams.first
    assert_instance_of GameTeam, @game_team_collection.games_by_teams.last
    assert_equal 20, @game_team_collection.games_by_teams.length
  end

  def test_it_can_return_all_game_team_objects
    assert_equal @game_team_collection.games_by_teams, @game_team_collection.all
  end
end
