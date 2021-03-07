// Macro for running Panda simulation  with Geant3  or Geant4 (M. Al-Turany)
// This macro is supposed to run the full simulation of the panda detector
// to run the macro:
// root  sim_complete.C  or in root session root>.x  sim_complete.C
// to run with different options:(e.g more events, different momentum, Geant4)
// root  sim_complete.C"(100, "TGeant4",2)"

//BeamMomentum=7.0 -> CM energy at X(3872) mass
void sim_complete(TString prefix="1", Int_t nEvents = 10, TString  inputGen ="llbar_fwp.DEC", Double_t BeamMomentum = 1.642)
{

	if (prefix=="" || inputGen=="" || BeamMomentum==0.)
	{
		std::cout << "USAGE:\n";
		std::cout << "sim_complete.C( <pref>,  <nevt>, <gen>, <pbeam> )\n\n";
		std::cout << "   <pref>     : output file names prefix\n";
		std::cout << "   <nevt>     : number of events\n";
		std::cout << "   <gen>      : generator input: EvtGen decfile; DPM/FTF/BOX uses DPM/FTF generator (inelastic mode) or BOX generator instead\n";
		std::cout << "                DPM settings: DPM  = inelastic only,  DPM1 = inel. + elastic, DPM2 = elastic only\n";
		std::cout << "                FTF settings: FTF  = inel. + elastic, FTF1 = inelastic only\n";
		std::cout << "                BOX settings: type[pdgcode,mult] and optional ranges 'p/tht/phi[min,max]' separated with colon; example: 'BOX:type[211,1]:p[1,5]:tht[45]:phi[90,210]'\n";
		std::cout << "   <pbeam>    : pbar momentum (for BOX generator it still controls the magnetic field) \n\n";
		std::cout << "Example 1 : root -l -b -q 'prod_sim.C(\"EvtD0D0b\", 100, \"D0toKpi.dec:pbarpSystem0\", 12.)'\n";
		std::cout << "Example 2 : root -l -b -q 'prod_sim.C(\"DpmInel\",  100, \"DPM\", 12.)'\n";
		std::cout << "Example 3 : root -l -b -q 'prod_sim.C(\"SingleK\",  100, \"BOX:type[321,1]:p[0.1,10]:tht[22,140]:phi[0,360]\", 12.)'\n\n";

		return;
	}

	// set random random seed
	gRandom->SetSeed();

	double mp = 0.938272;

	// if BeamMomentum<0, it's -E_cm -> compute momentum
	if (BeamMomentum<0)
	{
		double X = (BeamMomentum*BeamMomentum-2*mp*mp)/(2*mp);
		BeamMomentum = sqrt(X*X-mp*mp);
	}

	// Allow shortcut for resonance
	if (inputGen.Contains(":pbp")) inputGen.ReplaceAll(":pbp",":pbarpSystem");

	//-----User Settings:-----------------------------------------------
	//TString  parAsciiFile   = "all_day1.par";
	TString  parAsciiFile   = "all.par";
	TString  SimEngine      = "TGeant4";
	//TString  inputDir = "/lustre/nyx/panda/walter/development/wandersson/Macros/xiximacros/prod/";
	//TString decayMode = inputDir+"UserDecayConfig.C";
	// ---- check flag for DPM/FTF -------------------------------------
	Int_t    genflag = 0;
	if (inputGen=="DPM1" || inputGen=="FTF1") genflag=1;
	if (inputGen=="DPM2") genflag=2;

	//-------------------------------------------------------------------------
	// -----   Create the Simulation run manager ------------------------------
	PndMasterRunSim *fRun = new PndMasterRunSim();
	fRun->SetInput(inputGen);
	fRun->SetDpmFlag(genflag);
	fRun->SetFtfFlag(genflag);
	fRun->SetName(SimEngine);
	//if (!inputGen.Contains("dpm")) {
	//	fRun->SetUserDecay(decayMode);
	//}
	fRun->SetParamAsciiFile(parAsciiFile);
	fRun->SetNumberOfEvents(nEvents);
	fRun->SetBeamMom(BeamMomentum);
	// -----  Initialization   ------------------------------------------------
	fRun->Setup(prefix);
	// -----   Geometry   -----------------------------------------------------
	fRun->CreateGeometry();
	// -----   Event generator   ----------------------------------------------
	fRun->SetGenerator();
/*
	// -----   Event filter setup   -------------------------------------------
	FairFilteredPrimaryGenerator *primGen = fRun->GetFilteredPrimaryGenerator();
	primGen->SetVerbose(0);
	// ---- Example configuration for the event filter ------------------------
	FairEvtFilterOnSingleParticleCounts* chrgFilter = new FairEvtFilterOnSingleParticleCounts("chrgFilter");
	chrgFilter->AndMinCharge(4, FairEvtFilter::kCharged);
	
	PndEvtFilterOnInvMassCounts* mlamInv= new PndEvtFilterOnInvMassCounts("mlamInvMFilter");
	mlamInv->SetVerbose();//highest commenting level of the FairEvtFilterOnSingleParticleCounts
	mlamInv->SetPdgCodesToCombine( 2212, -211);
	mlamInv->SetMinMaxInvMass( 1.015683, 1.215683 );
	mlamInv->SetMinCounts(1);
	
	PndEvtFilterOnInvMassCounts* mlambInv= new PndEvtFilterOnInvMassCounts("mlambInvMFilter");
	mlambInv->SetVerbose();//highest commenting level of the FairEvtFilterOnSingleParticleCounts
	mlambInv->SetPdgCodesToCombine( -2212, 211);
	mlambInv->SetMinMaxInvMass( 1.015683, 1.215683 );
	mlambInv->SetMinCounts(1);
	
	primGen->AndFilter(chrgFilter);
	primGen->AndFilter(mlamInv);
	primGen->AndFilter(mlambInv);
*/

	// -----   Add tasks   ----------------------------------------------------
	fRun->AddSimTasks();
	// -----   Intialise and run   --------------------------------------------
	fRun->Init();
	fRun->Run(nEvents);
 	//primGen->WriteEvtFilterStatsToRootFile();
	fRun->Finish();
};

