package rw.ui.game;

import rw.ui.game.rh.stage.*;
import rw.ui.game.rh.stages.*;
import rw.ui.game.walker.stage.*;
import rw.ui.game.walker.stages.*;

class StageManager
{
	public static function getRhythmHeaven(stage:String):RHStage
	{
		return switch (stage.toLowerCase())
		{
			case 'stage':
				new RHStageMain(stage);

			default:
				trace('Unimplemented RH stage case : $stage');
				new RHStage(stage);
		}

	}

	public static function getWalker(stage:String):WalkerStage
	{
		return switch (stage.toLowerCase())
		{
			case 'chase-1', 'chase-2', 'chase-3':
				new StageChase(stage.toLowerCase());

			case 'save-1', 'save-2', 'save-3', 'save-4':
				new StageSave(stage.toLowerCase());

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
				trace('Unimplemented walker stage case : $stage');
				new WalkerStage(stage);
		}
	}
}
