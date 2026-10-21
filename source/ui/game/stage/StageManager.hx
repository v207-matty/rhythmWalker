package ui.game.stage;

class StageManager
{
	public static function get(stage:String)
	{
		return switch (stage.toLowerCase())
		{
			case 'chinatown':
				new StageChinatown();

			case 'stage-withered':
				new StageMainWithered();

			case 'stage' | 'understage':
				new StageMain(stage);

			default:
				new Stage(stage);
		}
	}
}
