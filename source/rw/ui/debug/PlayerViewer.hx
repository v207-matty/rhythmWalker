// #if PLAYER_VIEWER
package rw.ui.debug;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import rw.ui.game.player.Player;
import haxe.io.Path;
import lime.utils.Assets;

using StringTools;

class PlayerViewer extends ConductorState
{
	var entries:Array<String> = [];

	function getEntries()
	{
		final directory = 'assets/game/players';

		entries = [];

		for (path in Assets.list())
		{
			if (!path.startsWith(directory)) continue;

			var file = new Path(path);

			if (file.ext != 'json') continue;

			entries.push(file.file);
		}

		trace(entries);
	}

	var player:Player;
	var animations:Array<String> = [];

	var text:FlxText;

	override function create()
	{
		super.create();

		FlxG.camera.bgColor = FlxColor.GRAY;

		getEntries();

		add(player = new Player(null));
		switchPlayer(entries[0]);

		add(text = new FlxText(0, 0, 0, '', 16));
		text.x = text.y = text.size;

		persistentUpdate = true;
	}

	function switchPlayer(to:String)
	{
		if (!entries.contains(to)) return;

		player.load(to);

		player.setScale(2);
		player.screenCenter();

		animations = player.animation.getNameList();
		setAnim(animations[0]);
	}

	function setAnim(anim:String)
	{
		player.playAnim(anim, true);
		player.flipX = anim.endsWith('R');
	}

	function currentAnimIndex() return animations.indexOf(player.animation.name);

	function currentPlayerIndex() return entries.indexOf(player.data.id);

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([A, LEFT])) changePlayer(-1);
		if (FlxG.keys.anyJustPressed([D, RIGHT])) changePlayer(1);

		if (FlxG.keys.anyJustPressed([W, UP])) changeAnim(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN])) changeAnim(1);

		if (FlxG.keys.justPressed.SPACE) changeAnim(0);

		text.text = 'Player: ${player.data.id}\n' + 'Animation: ${player.animation.name}\n\n' + 'Frames: ${player.animation.curAnim.frames}\n'
			+ 'FPS: ${player.animation.curAnim.frameRate}\n' + 'Looped: ${player.animation.curAnim.looped}\n' + 'FlipX: ${player.animation.curAnim.flipX}\n';
	}

	function changePlayer(by:Int)
	{
		var target = currentPlayerIndex() - by;

		if (target < 0) target = entries.length - 1;
		if (target > entries.length - 1) target = 0;

		switchPlayer(entries[target]);
	}

	function changeAnim(by:Int)
	{
		var target = currentAnimIndex() - by;

		if (target < 0) target = animations.length - 1;
		if (target > animations.length - 1) target = 0;

		setAnim(animations[target]);
	}
}
// #end
