// Macro for running Panda digitization, reconstruction and pid tasks
// to run the macro:
// root  full_complete.C  or in root session root >.x  full_complete.C
int prod_aod(Int_t nEvents=10, TString prefix="ll") {
    
    if (prefix == "") 
    {
        std::cout << "USAGE:\n";
        std::cout << "prod_aod.C(<nevts>, <prefix> )\n\n" << std::endl;
        std::cout << "<pref> : input/output file names prefix\n\n" << std::endl;
        return 0;
    }
    
    std::cout << "FLAGS: " << nEvents << "," << prefix << std::endl;
    
    //***
    //----- User Settings
    TString parAsciiFile = "all.par";
    //TString prefix       = "llbar_fwp";      // "llbar_fwp", "evtcomplete";
    TString input        = "";                 // "dpm", "llbar_fwp.DEC";
    TString friend1      = "sim";
    TString friend2      = "digi";
    TString friend3      = "reco";
    TString friend4      = "";
    TString output       = "pid";
    
    // Note that the default tracker is BarrelTrackFinder.
    // Either set fOption="barreltrack" or leave it empty.
    // Set fOptions="stttracking" for IdealTrackFinder.
    TString fOption      = "stttracking";
    
    //***
    //----- Init Settings    
    PndMasterRunAna *fRun = new PndMasterRunAna();
    
    fRun->SetInput(input);
    //fRun->AddFriend(friend1);
    //fRun->AddFriend(friend2);
    //fRun->AddFriend(friend3);
    //fRun->AddFriend(friend4);
    fRun->SetOutput(output);
    fRun->SetParamAsciiFile(parAsciiFile);
    fRun->Setup(prefix);
    
    //----- Add Options
    if (fOption != "")
        fRun->SetOptions(fOption);
    
    //***
    //----- AOD Tasks
    fRun->AddDigiTasks(kFALSE);
    fRun->AddRecoTasks(kFALSE);
    fRun->AddPidTasks();
    
    //***
    //----- Intialise & Run
    PndEmcMapper::Init(1);
    fRun->Init();
    fRun->Run(0, nEvents);
    fRun->Finish();
    return 0;
}
