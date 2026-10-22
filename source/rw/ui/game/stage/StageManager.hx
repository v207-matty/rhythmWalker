package rw.ui.game.stage;

import rw.ui.game.stages.*;

class StageManager
{
	public static function get(stage:String)
	{
		return switch (stage.toLowerCase())
		{
			case 'chase':
				new StageChase();

			case 'chinatown':
				new StageChinatown();

			case 'chinatown-bridge':
				new StageChinatownBridge();

			case 'containment-04':
				new StageContainment04();

			case 'crash landing':
				new StageCrashLanding();

			case 'stage' | 'understage':
				new StageMain(stage);

			case 'stage-withered':
				new StageMainWithered();

			case 'train-getaway':
				new StageTrainGetaway();

			case 'train-wreak':
				new StageTrainWreak();

			default:
				trace('Unimplemented stage case : $stage');
				new Stage(stage);
		}
	}
}
