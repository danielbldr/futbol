class Game
  attr_reader :game_id, :season, :type, :date_time, :away_team_id, :home_team_id,
               :home_goals, :away_goals, :venue, :venue_link

  def initialize(game_params)
    @game_id = game_params[:game_id].to_i #used
    @season = game_params[:season] #used
    @type = game_params[:type]
    @date_time = game_params[:date_time]
    @away_team_id = game_params[:away_team_id].to_i
    @home_team_id = game_params[:home_team_id].to_i
    @home_goals = game_params[:home_goals].to_i #used
    @away_goals = game_params[:away_goals].to_i #used
    @venue = game_params[:venue]
    @venue_link = game_params[:venue_link]
  end
end
