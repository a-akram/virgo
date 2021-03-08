## Standard Target

```bash
# reaction
ppbar --> lambda + lambdabar --> p + piminus + c.c
```

```bash
# notation
pbarp	          pbarp
pbarp_d0          lambdabar
pbarp_d0d0        pbar (antiproton)
pbarp_d0d1        pi+
pbarp_d1          lambda
pbarp_d1d0        p (proton)
pbarp_d1d1        pi-
```

### _Important Information_

- 10000
- `ana_ntp.C` for `fwp, bkg, dpm` for consistencey. For `fwp/signal` the _**FairTask**_ `ana_ideal.C or anaideal.C` can be used. However, this might not work for _**Non-resonant background**_.
- copy `ntpBestPbarP.C, ntpBestPbarP.h` accross folders


    - 1_fwp for signal
    - 2_bkg for non-resonant bkg
    - 3_dmp for generic bkg