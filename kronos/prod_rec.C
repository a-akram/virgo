void prod_rec(TString prefix="")
{
  //-----User Settings:------------------------------------------------------
  TString  parAsciiFile   = "all.par";
  TString  output         = "reco";
  TString  friend1        = "sim";
  TString  friend2        = "digi";
 
  // -----   Initial Settings   --------------------------------------------
  PndMasterRunAna *fRun= new PndMasterRunAna();
  fRun->SetInput("dummy");
  fRun->SetOutput(output);
  fRun->AddFriend(friend1);
  fRun->AddFriend(friend2);
  fRun->SetParamAsciiFile(parAsciiFile);
  fRun->Setup(prefix);
  
  // -----   Add tasks   ----------------------------------------------------
  fRun->AddRecoIdealTasks();
  
  // -----   Intialise and run   --------------------------------------------
  PndEmcMapper::Init(1);
  fRun->Init();
  fRun->Run(0);
  fRun->Finish();
}
