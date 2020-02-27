require './test/test_helper'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/team_collection'


class TeamCollectionTest < Minitest::Test
  def setup
    @csv_file_path = "./test/fixtures/teams_truncated.csv"
    @team_collection = TeamCollection.new(@csv_file_path)
  end

  def test_it_exists
    assert_instance_of TeamCollection, @team_collection
  end

  def test_it_has_attributes
    assert_equal [], @team_collection.teams
    assert_equal "./test/fixtures/teams_truncated.csv", @team_collection.csv_file_path
  end

  def test_it_can_instantiate_a_game_object
    info = {team_id: "6", franchiseid: "6", teamname: "FC Dallas",
            abbreviation: "DAL", stadium: "Toyota Stadium", link: "/api/v1/teams/6"}
    team = @team_collection.instantiate_team(info)

    assert_instance_of Team, team
    assert_equal 6, team.team_id
    assert_equal "FC Dallas", team.team_name
  end

  def test_it_can_collect_team
    info = {team_id: "6", franchiseid: "6", teamname: "FC Dallas",
            abbreviation: "DAL", stadium: "Toyota Stadium", link: "/api/v1/teams/6"}
    team = @team_collection.instantiate_team(info)
    @team_collection.collect_team(team)

    assert_equal [team], @team_collection.teams
  end

  def test_it_can_create_team_collection
    @team_collection.create_team_collection

    assert_equal 9, @team_collection.teams.length
    assert_instance_of Team, @team_collection.teams.first
    assert_instance_of Team, @team_collection.teams.last
  end

  def test_it_can_return_all_teams
    @team_collection.create_team_collection

    assert_equal @team_collection.teams, @team_collection.all
  end

  def test_it_can_make_an_array_based_on_key
    @team_collection.create_team_collection
    expected_team_id = [3, 4, 6, 12, 17, 19, 23, 24, 29]
    expected_team_name = ["FC Dallas", "Houston Dynamo",
                          "Philadelphia Union", "Real Salt Lake",
                          "Sky Blue FC", "Orlando Pride", "LA Galaxy",
                          "Montreal Impact", "Chicago Fire"]

    assert_equal expected_team_id, @team_collection.array_by_key(:team_id).sort
    assert_equal expected_team_name, @team_collection.array_by_key(:team_name)
  end

  def test_it_can_find_a_team_name_when_given_id
    @team_collection.create_team_collection

    assert_equal "FC Dallas", @team_collection.where_id(6)
    assert_equal "LA Galaxy", @team_collection.where_id(17)
  end
end
