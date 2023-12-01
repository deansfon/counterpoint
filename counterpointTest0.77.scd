/*This is a simple program to pseudorandomly generate freqencies to make counterpoint harmonies/melodies.
It somewhat loosely follows 1st-species rules.
The scale degrees and harmonies use just-intonation ratios from the harmonic series.
An FM synthesizer is used for some timbral variety.*/

~counterPointFunc.value(); 	//play, for convenience
q.stop; 					//stop for convenience

(
~counterPointFunc = {
	arg scaleDegreeOne = 128;

~scaleDegreeOne = scaleDegreeOne;

Routine({

(
SynthDef.new(\fm, {
	arg freq, atk, rel, pos, amp,
	mRatio, cRatio, index, iScale;

	var car, mod, env;

	env = EnvGen.kr(
		Env.perc(atk, rel),
		doneAction: 2
	);

	index = EnvGen.kr(
		Env.new(
			levels: [index, index * iScale, index],
			times: [atk, rel]
		),
		doneAction: 2

	);

	mod = SinOsc.ar(freq * mRatio, mul: freq * mRatio * index);
	car = SinOsc.ar((freq * cRatio) + mod);

	car = car * env * amp;
	car = Pan2.ar(car, pos);

	Out.ar(0, car);
}).add;
);

0.1.wait;

(
~root = ~scaleDegreeOne; //initialize some environment var
~harm = (~root * 5/4);
~newRoot = (~scaleDegreeOne - 1);
~newHarm = 1;
~prevRoot = (~scaleDegreeOne - 2);
~prevHarm = 1000;
~count = 0;
~dur = inf;
~harmDifference = 2;

~scale = ~scaleDegreeOne * [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8]; //3 8ves of Cmaj scale w/ just intervals
~scalePlusOct = ~scale * 2;
~scaleMinusOct = ~scale * 4;
~scale = ~scale ++ ~scalePlusOct ++ ~scaleMinusOct;

~scaleIndex = -1;
~oldIndex = 0;

(					//method for determining the counterpoint harmonies
~harmonyMethod = {
	~newHarm = case


	//middle C + or - 1 8ve
	{ 	(~newRoot == ( (~scaleDegreeOne * 1) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 1) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 1) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [5/4, 4/3, 3/2, 5/3, 9/4].wchoose(
																[4,   2,   2,   2,   1   ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 9/8) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 9/8) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 9/8) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [6/5, 4/3, 3/2, 9/5, 9/4].wchoose(
																[4,   2,   2,   1,   1  ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 5/4) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 5/4) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 5/4) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [6/5, 4/3, 3/2].wchoose(
																[4,   2,   2  ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 4/3) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 4/3) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 4/3) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [5/4, 3/2, 5/3, 45/32, 9/4].wchoose(
																[4,   2,   2,   3,     1    ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 3/2) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 3/2) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 3/2) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [5/4, 4/3, 3/2, 5/3, 9/5, 9/4].wchoose(
																[4,   2,   2,   2,   1,   1  ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 5/3) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 5/3) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 5/3) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [6/5, 4/3, 3/2, 9/5, 9/4].wchoose(
																[4,   2,   2,   1,   1  ].normalizeSum)
	}
	{ 	(~newRoot == ( (~scaleDegreeOne * 15/8) * (1) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 15/8) * (2) ) ) ||
		(~newRoot == ( (~scaleDegreeOne * 15/8) * (4) ) )
	}
										{ ~newHarm = ~newRoot * [6/5, 45/32].wchoose(
																[1,   1    ].normalizeSum)
	}

};
)

);

0.1.wait;

(
p = Pbind(
	\instrument, \fm,

	\freq, Pfunc({
		var output;


		while (	//while these conditions are true, keep pseudorandomly generating a new harmony note

			{
				(
					//in the scale

					(
						((~scale.includes(~newRoot)) == false)
					).or

					//different each time

					(
						(~newRoot == ~root).or
						(~newHarm == ~harm)
					).or

					//harmony always different

					 ((
						( ~harmDifference < (25/24) ).and
						( ~count > 1)
					)).or

					(
						(~newHarm == ~harm)
					).or

					//contrary motion

					((
						(~root > ~prevRoot).and
						(~newRoot > ~root)
					).and(
						(~harm > ~prevHarm).and
						(~newHarm > ~harm)
					)).or

					((
						(~root < ~prevRoot).and
						(~newRoot < ~root)
					).and(
						(~harm < ~prevHarm).and
						(~newHarm < ~harm)
					)).or

					//no parallel P5

					((
						( (~harm / ~root) == (3/2) ).and
						( (~newHarm / ~newRoot) == (3/2) )
					)).or

					//no hidden P5

					((
						(~root > ~prevRoot).and
						(~harm > ~prevHarm)
					).and(
						( (~harm / ~root) == (3/2) )
					)).or

					((
						(~root < ~prevRoot).and
						(~harm < ~prevHarm)
					).and(
						( (~harm / ~root) == (3/2) )
					)).or

					//no parallel P4

					((
						( (~harm / ~root) == (4/3) ).and
						( (~newHarm / ~newRoot) == (4/3) )
					)).or

					//no hidden P4

					((
						(~root > ~prevRoot).and
						(~harm > ~prevHarm)
					).and(
						( (~harm / ~root) == (4/3) )
					)).or

					((
						(~root < ~prevRoot).and
						(~harm < ~prevHarm)
					).and(
						( (~harm / ~root) == (4/3) )
					)).or

					//no parallel TT

					((
						( (~harm / ~root) == (45/32) ).and
						( (~newHarm / ~newRoot) == (45/32) )
					)).or

					//no parallel M7

					((
						( (~harm / ~root) == (15/8) ).and
						( (~newHarm / ~newRoot) == (15/8) )
					)).or

					//no parallel m7

					((
						( (~harm / ~root) == (9/5) ).and
						( (~newHarm / ~newRoot) == (9/5) )
					)).or

					//no parallel 8ve

					((
						( (~harm / ~root) == (2) ).and
						( (~newHarm / ~newRoot) == (2) )
					)).or

					//no hidden 8ve

					((
						(~root > ~prevRoot).and
						(~harm > ~prevHarm)
					).and(
						( (~harm / ~root) == (2) )
					)).or

					((
						(~root < ~prevRoot).and
						(~harm < ~prevHarm)
					).and(
						( (~harm / ~root) == (2) )
					)).or

					//law of recovery-ish

					((
						((~newRoot / ~root) >= (4/3)) .and
						((~root / ~prevRoot) >= (4/3))
					).or(
						((~root / ~newRoot) >= (4/3)).and
						((~prevRoot / ~root) >= (4/3))
					)).or

					//minimal root motion

					((
						((~newRoot / ~root) > (5/4)).and
						((~root / ~prevRoot) > (5/4))
					).or(
						((~root / ~newRoot) > (5/4)).and
						((~prevRoot / ~root) > (5/4))
					)).or

					//minimal harm motion (avoid leaps from the 8ve multiplier)

					((
						((~newHarm / ~harm) > (3/2)).and
						((~harm / ~prevHarm) > (3/2))
					).or(
						((~harm / ~newHarm) > (3/2)).and
						((~prevHarm / ~harm) > (3/2))
					)).or

					//avoid voice crossing
					(
						(~count > 1).and
						(
							(~harm < ~prevRoot).or
							(~root > ~prevHarm)
						)
					)
				)

			},

			{

				//need ~scaleIndex to always be non negative
				~scaleIndex = (~oldIndex + ( ((1..8).wchoose( [17, 5, 5, 3, 2, 2, 1, 1].normalizeSum)) * ([-1, 1].choose) ) );

				while (
					{ (~scale.includes(~scale.at(~scaleIndex)) == false) },
					{ ~scaleIndex = (~oldIndex + ( ((1..8).wchoose( [17, 5, 5, 3, 2, 2, 1, 1].normalizeSum)) * ([-1, 1].choose) ) ) }
				);

				~newRoot = ( ~scale.at(~scaleIndex) );

				~harmonyMethod.value;

				if (
					(
						((
							(~root > ~prevRoot).and
							(~newRoot > ~root)
						).and(
							(~harm > ~prevHarm).and
							(~newHarm > ~harm)
						)).or

						((
							(~root < ~prevRoot).and
							(~newRoot < ~root)
						).and(
							(~harm < ~prevHarm).and
							(~newHarm < ~harm)
						))

					),

					{
						[nil, ~harmonyMethod.value;].wchoose([1, 3].normalizeSum);
					}

				);

				if (
					(~newHarm <= ~prevHarm),

					{	(~harmDifference = (~prevHarm / ~newHarm) )},
					{	(~harmDifference = (~newHarm / ~prevHarm) )}
				);

		});

		if (
			(~count < 1),

			{	(~newRoot = ~scaleDegreeOne);				//start on tonic
				(~newHarm = (~root * 5/4) );	//and a maj 3rd above
			}
		);

		if (
			(~count > 20).and

			/* ((~count % 4) == 0).and */

			(
				(
					(
						( (~prevRoot == (~scaleDegreeOne * (15/8) ) )        ).and
						( (~newRoot == ( ~scaleDegreeOne * 2) ) )
					)
				).or

				(
					( (~prevRoot == ( (~scaleDegreeOne * (15/8) ) * 2) ) ).and
					( (~newRoot == ( ~scaleDegreeOne * 4) ) )

				).or

				(
					( (~prevRoot == ( (~scaleDegreeOne * (3/2) ) * 2) ) ).and
					( (~newRoot == ( ~scaleDegreeOne * 4) ) )

				).or

				(
					( (~prevRoot == ( (~scaleDegreeOne * (3/2) ) ) ) ).and
					( (~newRoot == ( ~scaleDegreeOne * 2) ) )

				)


			).and

			(
				( (~harm == (~newRoot * 5/4) ) )
			),

			{
				(q.stop;)
			}
		);

		~prevRoot = ~newRoot;
		~prevHarm = ~newHarm;
		~harm = ~newHarm;
		~root = ~newRoot;

		~oldIndex = ~scaleIndex;

		~count = (~count + 1);


		if (
			(
				(~count > 800)
			),

			{
				(q.stop;)
			}

		);


		~count.postln; //output the count
		~dur.postln;
		(~harm / ~root).asFraction.postln; //output the intervallic ratio
		([~root, ~harm]).postln; //output the frequencies
		~harmDifference.postln; //for de-bugging purposes

		output = [~root, ~harm];

	}),

	\dur, Pseq([0.5], ~dur),
	\mRatio, Prand([1, 2], inf),
	\cRatio, Prand([1], inf),
	\pos, Pwhite(-1, 1, inf),
	\atk, 0.05,
	\rel, 0.45,
	\index, Pwhite(1, 2, inf),
	\amp, 0.75,
	\iScale, Pwhite(1, 2, inf)
);

);

0.1.wait;

q = p.play;

}).play;

};
)