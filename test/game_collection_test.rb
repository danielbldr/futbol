require './test/test_helper'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/game_collection'


class GameCollectionTest < Minitest::Test
  def setup
    @csv_file_path = "./test/fixtures/games_truncated.csv"
    @game_collection = GameCollection.new(@csv_file_path)
  end

  def test_it_exists
    assert_instance_of GameCollection, @game_collection
  end

  def test_it_has_attributes
    assert_equal [], @game_collection.games
    assert_equal "./test/fixtures/games_truncated.csv", @game_collection.csv_file_path
  end

  def test_it_instantiate_a_game_object
    info = {
      game_id: "2012030221", season: "20122013", type: "Postseason",
      date_time: "5/16/13", away_team_id: "3", home_team_id: "6", away_goals: "2",
      home_goals: "3", venue: "Toyota Stadium", venue_link: "/api/v1/venues/null"
    }
    game = @game_collection.instantiate_game(info)

    assert_instance_of Game, game
    assert_equal 2012030221, game.game_id
    assert_equal "Postseason", game.type
    assert_equal 3, game.away_team_id
  end

  def test_game_can_be_collected
    info = {
      game_id: "2012030221", season: "20122013", type: "Postseason",
      date_time: "5/16/13", away_team_id: "3", home_team_id: "6", away_goals: "2",
      home_goals: "3", venue: "Toyota Stadium", venue_link: "/api/v1/venues/null"
    }
    game = @game_collection.instantiate_game(info)
    @game_collection.collect_game(game)

    assert_equal [game], @game_collection.games
  end

  def test_games_can_be_created_through_csv
    @game_collection.create_game_collection

    assert_instance_of Game, @game_collection.games.first
    assert_instance_of Game, @game_collection.games.last
    assert_equal 10, @game_collection.games.length
  end

  def test_it_can_return_total_scores_per_game
    @game_collection.create_game_collection
    expected = [5, 5, 3, 5, 4, 3, 5, 5, 6, 4]

    assert_equal expected, @game_collection.total_goals_per_game(@game_collection.all)
  end

  def test_it_can_return_all_games
    @game_collection.create_game_collection

    assert_equal @game_collection.games, @game_collection.all
  end

  def test_it_can_make_an_array_based_on_key
    @game_collection.create_game_collection
    season_expected = ["20122013", "20132014"]
    game_id_expected = [2012030221, 2012030222, 2012030223, 2012030224, 2012030225,
                        2013020674, 2013020177, 2012020225, 2012020577, 2013021085]

    assert_equal season_expected, @game_collection.array_by_key(:season)
    assert_equal game_id_expected, @game_collection.array_by_key(:game_id)
  end

  def test_it_can_count_the_games_by_season
    @game_collection.create_game_collection
    expected = {"20122013"=>7, "20132014"=>3}

    assert_equal expected, @game_collection.count_of_games_by_season
  end

  def test_it_can_return_games_by_season
    @game_collection.create_game_collection
    game_1_info = {game_id: "2012030221", season: "20122013", type: "Regular Season"}
    game_2_info = {game_id: "2012030222", season: "20132014", type: "Regular Season"}
    game1 = Game.new(game_1_info)
    game2 = Game.new(game_2_info)
    @game_collection.stubs(:all).returns([game1, game2])
    expected = {"20122013" => [game1],
                "20132014" => [game2]}

    assert_equal expected, @game_collection.games_by_season
  end

  def test_it_can_return_average_goal_by_season
    @game_collection.create_game_collection
    expected = {"20122013"=>4.71, "20132014"=>4.00}

    assert_equal expected, @game_collection.average_goals_by_season
  end
end
