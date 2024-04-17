//Synthesis and mapping osc messages to Wekinator.

(

var synth, responder;

synth = SynthDef("WekiSynth",

	{

	| gate=1,freq=120,freqLo=10,freqHi=0.1,freq3=0.4,freq6=10,ch=0.3,surface=0.0001,
		amp1=0.000001,amp2=0.0000001,amp3=0.0000001,amp4=0.000001,amp5=0.0000001,amp6=0.000001,
		 del=0.001, dec=0.005,rate=0.05,freq4=120,freq5=100,
		modFreq=0.01, panFreq = 0.5,
		mix1=1.0,mix2=1.0,lop=18000, hip=20, lopVol=0.5, hipVol=0.5, entropy=14, length=5
		|
var signal2,sig2,env,pan,signal, effect, times = 20,signal3,signal4,chain,formlet,sig3,all,sig4,sig5,sig6,thres,osc,sig7;
		env= EnvGen.kr(Env.asr(7.8,3.2,3.6), gate, doneAction:2);


		signal= Fold.ar(
	SinOscFB.ar([30,32], LFNoise1.ar(freq).range(0.1,2.5)), // src
	freq, // lo
	SinOsc.ar([0.03,0.1]).range(0.5,12.0) // hi
) *env;


		signal2= Resonz.ar(Mix(Saw.ar(freqLo*[1,0.9,0.8,0.7,0.5])),freqHi,0.1,2);
sig2 = (signal2 ) + LPCError.ar(signal2, 4.6) * 0.00003;
		sig2 = (BLowPass4.ar(sig2, modFreq*900, 0.25, mul:0.5) + BHiPass4.ar(sig2, 2, 0.25, mul:0.5))*0.000000000000000001;
sig2 = sig2 * env;


		sig3=OFDagal.ar(57, rate:rate, resTo:1, lpf:100, mul:2)*env;

		sig4=HPF.ar(PMOsc.ar(freq4,
		 	Lag.ar(
		 	LFDClipNoise.ar(2).range(0.02,10), 0.01),[10, 1000]).fold2(SinOsc.ar(freq4*0.001)),
		 LFNoise1.ar(16).range(0.1,23000), 0.3)*0.8*env;
	 sig4=Limiter.ar([sig4],0.02);


		 sig5 = VarSaw.ar(LFPar.ar(freq5/[10,8], 0, 10, LFPar.kr(5, 0, 5, 40)), 0, LFNoise2.kr(freq5/3, 0.5, 1.5)) * 0.6;
		thres = Lag.kr(Amplitude.kr(sig5), 0.1);
		osc = Splay.ar(Pulse.ar(Array.series(10, freq5*0.02, 5))) * thres;
		sig5 = osc + BPeakEQ.ar(BBandStop.ar(sig5, LFNoise1.kr(0.5, 600, 800), 8), 80, 3, -2);
		sig5=(HPF.ar(Splay.ar(sig5),60) * LFNoise1.ar(0.8).range(0.3,1.1))*env;


		sig6=FitzHughNagumo.ar(Impulse.kr(LFNoise1.kr([1,2],freq6/5,freq6)), surface.linlin(0.0, 1.0,0.0001,0.4), ch.linlin(0.0,1.0,0.0001,0.4),
		ch.linlin(0.0, 1.0, 0.01, 3),surface.linlin(0.0, 1.0, 0.01, 4),SinOsc.kr(20,0,0.7), SinOsc.kr(21,0,0.8)) * 0.4;
		sig6=LPF.ar(BHiPass4.ar(sig6 * 0.3, 500), 6000) * env;
		sig6=Limiter.ar([sig6],0.2);




		all= Mix.ar([signal*amp1,sig2*amp2,sig3*amp3,sig4*amp4,sig5*amp5,sig6*amp6]);
		Out.ar(0, all);
		//Out.ar(0, signal2);
		//Out.ar(4, (signal3 * (1 - mix1)) + (IFFT(chain).dup * mix1)*amp3);
		//ReplaceOut.ar(6, ((signal4 * (1 - mix2)) + (formlet * mix2))*amp4);
	}
).play;



~receiver.free; //free the old reciever if it already exists
~receiver = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr ... only the language port 57120 actually works
~responder.free; //if there is an old responder ... then free it first
~responder = OSCFunc(
	{ | msg |

		var specs = Array.newClear(14);

		msg.postln;

		specs[0] =  ControlSpec(0.01, 2,\lin);
		specs[1] =  ControlSpec(0.000001, 0.01,\exp);
		specs[2] = ControlSpec(10, 1200,\lin);
		specs[3] = ControlSpec(0.005, 900,\exp);
		specs[4] = ControlSpec(0.0000000000001, 0.0000009,\exp);
        specs[5] = ControlSpec(40, 90000,\lin);
		specs[6] = ControlSpec(0.0001, 0.09,\lin);
		specs[7] = ControlSpec(0.01, 130.09,\lin);
		specs[8] = ControlSpec(0.000001, 0.3,\exp);
		specs[9] = ControlSpec(30.1, 200.09,\lin);
		specs[10] = ControlSpec(0.000001, 0.02,\lin);
		specs[11] = ControlSpec(30.1, 1500.09,\lin);
		specs[12] = ControlSpec(0.000001, 0.2,\exp);
		specs[13] = ControlSpec(8.1, 20.09,\exp);


		synth.set(\freq, specs[0].map(msg[1]));
		synth.set(\amp1, specs[1].map(msg[2]));
		synth.set(\freqHi, specs[2].map(msg[3]));
		synth.set(\freqLo, specs[3].map(msg[4]));
        synth.set(\amp2,  specs[4].map(msg[5]));
		synth.set(\modFreq,  specs[5].map(msg[6]));
        synth.set(\amp3,  specs[6].map(msg[7]));
        synth.set(\rate,  specs[7].map(msg[8]));
        synth.set(\amp4,  specs[8].map(msg[9]));
        synth.set(\freq4,  specs[9].map(msg[10]));
		synth.set(\amp5,  specs[10].map(msg[11]));
        synth.set(\freq5,  specs[11].map(msg[12]));
		synth.set(\amp6,  specs[12].map(msg[13]));
        synth.set(\freq6,  specs[13].map(msg[14]));
	},
	'/wek/outputs');

)


