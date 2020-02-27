class GameTeam
  attr_reader :game_id, :team_id, :home_or_away, :result, :head_coach,
              :goals, :shots, :tackles

  def initialize(game_team_params)
    @game_id = game_team_params[:game_id].to_i #used
    @team_id = game_team_params[:team_id].to_i
    @home_or_away = game_team_params[:hoa] #used
    @result = game_team_params[:result] #used
    @head_coach = game_team_params[:head_coach] #used
    @goals = game_team_params[:goals].to_i # used
    @shots = game_team_params[:shots].to_i
    @tackles = game_team_params[:tackles].to_i
  end

end
