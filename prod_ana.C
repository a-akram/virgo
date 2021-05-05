int prod_ana(Int_t nEvents=10, TString prefix="ll", Bool_t IsSignal=true) {

	// *** the files coming from the simulation
	bool signal = true;
	bool isdpm = false;
	double beammom = 1.642;
	
	//TString inSimFile	= prefix+"_sim.root";			// this file contains the MC truth
	//TString inRecoFile= prefix+"_recoideal.root";		// this file contains recostructed candidates
	TString inPidFile	= prefix+"_pid.root";		    // this file contains the PndPidCandidates and McTruth
	TString inParFile	= prefix+"_par.root";			// this file contains parameters
	TString OutFile 	= prefix+"_ana.root";           // output file from PndLLbarAnaTaskRGIS()
	
	// *** PID table with selection thresholds; can be modified by the user
	TString pidParFile = TString(gSystem->Getenv("VMCWORKDIR"))+"/macro/params/all.par";	

    std::cout << "FLAGS: " << nEvents << ", " << prefix << ", " << IsSignal << std::endl;

	// *** initialization
	FairLogger::GetLogger()->SetLogToFile(kFALSE);
	FairRunAna *fRun = new FairRunAna();
	FairRuntimeDb *rtdb = fRun->GetRuntimeDb();
	//fRun->SetSource(new FairFileSource(inPidFile));       // OR
	FairFileSource *fSrc = new FairFileSource(inPidFile);
	fRun->SetSource(fSrc);
					
	
	// *** setup parameter database 	
	FairParRootFileIo* parIO = new FairParRootFileIo();
	parIO->open(inParFile);
	FairParAsciiFileIo* parIOPid = new FairParAsciiFileIo();
	parIOPid->open(pidParFile.Data(), "in");
	
	rtdb->setFirstInput(parIO);
	rtdb->setSecondInput(parIOPid);
	rtdb->setOutput(parIO);  
	fRun->SetOutputFile(OutFile);
	
	// *** HERE OUR TASK GOES!
	PndLLbarAnaTaskRGIS *anaTask = new PndLLbarAnaTaskRGIS();
	
	// True for Signal (Default), False for Non-resonant Bkg.
	anaTask->SetSignalSample(IsSignal);         
	fRun->AddTask(anaTask);
	
	// *** and run analysis
	fRun->Init(); 
	fRun->Run(0, nEvents);
	return 0;
}
