package ui.game.dialogue;

import util.Constants;
import util.Flag;
import ui.objects.mobile.CornerButton;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import ui.game.song.Song;

using StringTools;

class DialogueScene extends ConductorState
{
	public static var seenIntroCutscene:Bool = false;

	var song:Song;
	var dialogue:DialogueData;

	override public function new(song:Song)
	{
		super();

		this.song = song;

		seenIntroCutscene = true;

		var path = Paths.json('game/cutscenes/dialogue/${song.id.replace(' ', '-')}-${song.variation ?? defaultVariation}');
		trace(path);

		if (!Assets.exists(path))
			leave();

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

	var leaveButton:CornerButton;
	var proceedButton:CornerButton;

	override function create()
	{
		super.create();

		if (dialogue == null || leaving)
		{
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

		if (Flag.IS_MOBILE_MODE)
		{
			leaveButton = new CornerButton('backBtn');
			add(leaveButton);
			leaveButton.back.flipX = true;
			leaveButton.offsetBy(24, 0);
			leaveButton.onClicked.add(leave);

			proceedButton = new CornerButton('proceedBtn');
			add(proceedButton);
			proceedButton.x = FlxG.width - leaveButton.width;
			proceedButton.offsetBy(-8, 0);
			proceedButton.onClicked.add(() -> if (dialogueFinished) proceed());

			proceedText.text = 'ENTER or the play button to proceed\nESCAPE or the back button to skip';
		}

		proceedText.screenCenter();
		proceedText.y = FlxG.height - proceedText.height;

		startDialogue();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (dialogue == null || leaving)
			return;

		dialogueText.screenCenter(X);

		proceedText.alpha = FlxMath.lerp(proceedText.alpha, ((dialogueFinished) ? 1 : 0), .1);

		if (FlxG.keys.justPressed.ESCAPE)
			leave();

		if (FlxG.keys.justPressed.ENTER && dialogueFinished)
			proceed();
	}

	var leaving:Bool = false;

	function proceed()
	{
		currentLine++;

		if (currentLine > dialogue.lines.length - 1)
			leave();
		else
			startDialogue();
	}

	function startDialogue()
	{
		var line = dialogue?.lines[currentLine];

		proceedInTimer.cancel();

		for (event in line?.events ?? [])
			parseEvent(event);

		dialogueFinished = false;

		dialogueText.resetText(line?.text ?? '');
		dialogueText.start(0.04);

		if (line?.text?.trim()?.length < 1 && !proceedInTimer.active)
			dialogueFinished = true;

		if (characterLeft != null)
			characterLeft.alpha = (line?.speaker == 1) ? 1 : 0.5;

		if (characterRight != null)
			characterRight.alpha = (line?.speaker == 2) ? 1 : 0.5;
	}

	var proceedInTimer:FlxTimer;

	function parseEvent(event:DialogueEventData)
	{
		switch (event.id.toLowerCase())
		{
			case 'playsound':
				if (event.data == null)
					return;

				FlxG.sound.play(Paths.getAudio('game/cutscenes/${event.data}'));
			case 'characterswitch':
				if (event.data == null)
					return;

				if (Reflect.fields(event.data).contains('left'))
					characterLeft.switchPortrait(event.data.left);

				if (Reflect.fields(event.data).contains('right'))
					characterRight.switchPortrait(event.data.right);
			case 'proceedin':
				if (event.data == null)
					return;

				proceedInTimer.start(Std.parseFloat(Std.string(event.data)), t ->
				{
					proceed();
				});
		}
	}

	function leave()
	{
		leaving = true;

		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
