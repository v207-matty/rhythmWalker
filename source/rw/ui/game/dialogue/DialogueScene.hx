package rw.ui.game.dialogue;

import flixel.util.FlxColor;
import rw.util.Constants;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import rw.ui.game.song.SongData;

using StringTools;

class DialogueScene extends ConductorState
{
	var song:SongData;
	var skipping:Bool = false;
	var dialogue:DialogueData;

	override public function new(song:SongData, skipping = false)
	{
		super();

		this.song = song;
		this.skipping = skipping;

		var path = Paths.json('game/cutscenes/dialogue/${song.id.replace(' ', '-')}-${song.variation ?? defaultVariation}');
		trace(path);

		if (!Assets.exists(path)) leave();

		try
		{
			dialogue = Json.parse(Assets.getText(path));
		}
		catch (e)
		{
			trace(e);
			dialogue = null;
		}
	}

	var characterLeft:DialogueCharacter;
	var characterRight:DialogueCharacter;

	var dialogueText:FlxTypeText;
	var currentLine:Int = 0;
	var dialogueFinished:Bool = false;

	var proceedText:FlxText;

	override function create()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(.25);

		if (dialogue == null || leaving || skipping)
		{
			bgColor = Constants.TRANSITION_COLOR;
			transIn = transOut = null;
			leave();
			return;
		}

		characterLeft = new DialogueCharacter(dialogue?.characters?.left ?? null);
		characterRight = new DialogueCharacter(dialogue?.characters?.right ?? null);

		characterLeft.screenCenter(Y);
		characterRight.screenCenter(Y);

		characterLeft.x = characterLeft.width;
		characterRight.x = FlxG.width - (characterRight.width * 2);

		add(characterLeft);
		add(characterRight);

		dialogueText = new FlxTypeText(0, 0, 0, 'Lorem Ipsum Dolor Sit Amet', 32);
		add(dialogueText);

		dialogueText.sounds = [FlxG.sound.create(Paths.getAudio('game/cutscenes/dialogueText')),];
		dialogueText.finishSounds = true;

		dialogueText.screenCenter();
		dialogueText.y += dialogueText.height * 4;

		dialogueText.completeCallback = () -> dialogueFinished = true;

		proceedInTimer = new FlxTimer();

		proceedText = new FlxText(0, 0, 0, 'ENTER to proceed\nESCAPE to skip', Constants.TEXT_SIZE);
		add(proceedText);
		proceedText.alpha = 0;
		proceedText.alignment = CENTER;

		#if MOBILE_MODE
		var backBtn = new rw.ui.objects.mobile.CornerButton('backBtn');
		add(backBtn);
		backBtn.back.flipX = true;
		backBtn.offsetBy(24, 0);
		backBtn.onClicked.add(leave);

		var proceedBtn = new rw.ui.objects.mobile.CornerButton('proceedBtn');
		add(proceedBtn);
		proceedBtn.x = FlxG.width - proceedBtn.width;
		proceedBtn.offsetBy(-8, 0);
		proceedBtn.onClicked.add(() -> if (dialogueFinished) proceed());

		proceedText.text = 'ENTER or the play button to proceed\nESCAPE or the back button to skip';
		#end

		proceedText.screenCenter();
		proceedText.y = FlxG.height - proceedText.height;

		startDialogue();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (dialogue == null || leaving) return;

		dialogueText.screenCenter(X);

		proceedText.alpha = FlxMath.lerp(proceedText.alpha, ((dialogueFinished) ? 1 : 0), .1);

		if (FlxG.keys.justPressed.ESCAPE) leave();

		if (FlxG.keys.justPressed.ENTER && dialogueFinished) proceed();
	}

	var leaving:Bool = false;

	function proceed()
	{
		currentLine++;

		if (currentLine > dialogue.lines.length - 1) leave();
		else startDialogue();
	}

	function startDialogue()
	{
		var line = dialogue?.lines[currentLine];

		proceedInTimer.cancel();

		for (event in line?.events ?? []) parseEvent(event);

		dialogueFinished = false;

		dialogueText.resetText(line?.text ?? '');
		dialogueText.start(0.04);

		if (line?.text?.trim()?.length < 1 && !proceedInTimer.active) dialogueFinished = true;

		if (characterLeft != null) characterLeft.alpha = (line?.speaker == 1) ? 1 : 0.5;

		if (characterRight != null) characterRight.alpha = (line?.speaker == 2) ? 1 : 0.5;
	}

	var proceedInTimer:FlxTimer;

	function parseEvent(event:DialogueEventData)
	{
		switch (event.id.toLowerCase())
		{
			case 'playsound':
				if (event.data == null) return;

				FlxG.sound.play(Paths.getAudio('game/cutscenes/${event.data}'));
			case 'characterswitch':
				if (event.data == null) return;

				if (Reflect.fields(event.data).contains('left')) characterLeft.switchPortrait(event.data.left);

				if (Reflect.fields(event.data).contains('right')) characterRight.switchPortrait(event.data.right);
			case 'proceedin':
				if (event.data == null) return;

				proceedInTimer.start(Std.parseFloat(Std.string(event.data)), t ->
				{
					proceed();
				});
		}
	}

	function leave()
	{
		leaving = true;

		FlxG.switchState(GameManager.load(song?.mode ?? WALKER, {song: song.id, variation: song.variation}));
	}
}
