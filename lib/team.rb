class Team
  attr_reader :team_id, :team_name

  def initialize(team_params)
    @team_id = team_params[:team_id].to_i
    @team_name = team_params[:teamname]
  end
end
