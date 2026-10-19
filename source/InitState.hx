import util.Constants;
import util.Flag;
import ui.freeplay.Freeplay;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class InitState extends FlxState
{
	override function create()
	{
		super.create();

		if (!Flag.PLATFORM_WEB)
		{
			proceed();
			return;
		}

		var clickForSync:FlxText = new FlxText(0, 0, 0, 'Click Here (Or anywhere!)', Constants.TEXT_SIZE);
		add(clickForSync);
		clickForSync.screenCenter();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
			proceed();
	}

	function proceed()
	{
		if (Flag.STARTINGSTATE_GAMEPLAY)
			FlxG.switchState(() -> new PlayState('encapture'));
		else if (Flag.STARTINGSTATE_DIALOGUE)
			FlxG.switchState(() -> new ui.dialogue.DialogueScene(new song.Song('encapture')));
		else if (Flag.STARTINGSTATE_RESULTS)
			FlxG.switchState(() -> new ResultsState('train wreak-default'));
		else
			FlxG.switchState(() -> new Freeplay());
	}
}
