require './test/test_helper'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/team'

class TeamTest < Minitest::Test

  def test_it_exists
    info = {team_id: "6", franchiseid: "6", teamname: "FC Dallas",
            abbreviation: "DAL", stadium: "Toyota Stadium", link: "/api/v1/teams/6"}
    team = Team.new(info)

    assert_instance_of Team, team
  end

  def test_it_has_attributes
    info = {team_id: "6", franchiseid: "6", teamname: "FC Dallas",
            abbreviation: "DAL", stadium: "Toyota Stadium", link: "/api/v1/teams/6"}
    team = Team.new(info)

    assert_equal 6, team.team_id
    assert_equal "FC Dallas", team.team_name
  end
end
