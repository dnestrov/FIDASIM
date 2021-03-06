PRO calc_npa,grid,fbm,weights,los,neutrals,flux,prod,mean_fbm2

	nchan=los.nchan
	nen=weights.nen

    nen_transp=n_elements(fbm.energy)
    npitch_transp=n_elements(fbm.pitch) 
    dE_transp=fbm.energy[1]-fbm.energy[0]
    dpitch_transp=abs(fbm.pitch[1]-fbm.pitch[0])


    flux = fltarr(nen,nchan)
    mean_fbm = fltarr(nen_transp,npitch_transp,nchan)

    for ichan=0, nchan-1 do begin
        ;; ------------------------------------------
        ;;------------ CALCUATE mean value of fbm----
        ;; ------------------------------------------
        rad=0.d0
        for i=0,grid.nx-1 do begin
           for j=0,grid.ny-1 do begin
              for k=0,grid.nz-1 do begin
                 los_wght=los.weight[i,j,k,ichan]
                 if los_wght gt 0. then begin
                    ;; determine mean values like the halo density along LOS
                    wght=(  total(neutrals.fdens[i,j,k,*] + $
                            neutrals.hdens[i,j,k,*] + $
                            neutrals.tdens[i,j,k,*] + $
                            neutrals.halodens[i,j,k,*])) * los_wght
                    rad=rad+wght
					rrc=grid.r_grid[i,j,k]
					zzc=grid.w_grid[i,j,k]

                    dr=2.       ;[cm]
                    dz=2.       ;[cm]

                    dummy=min((fbm.r2d-rrc+dr)^2.+(fbm.z2d-zzc+dz)^2.,fbm_index1)
                    dummy=min((fbm.r2d-rrc-dr)^2.+(fbm.z2d-zzc+dz)^2.,fbm_index2)
                    dummy=min((fbm.r2d-rrc+dr)^2.+(fbm.z2d-zzc-dz)^2.,fbm_index3)
                    dummy=min((fbm.r2d-rrc-dr)^2.+(fbm.z2d-zzc-dz)^2.,fbm_index4)
                    dummy=min((fbm.r2d-rrc)^2.+(fbm.z2d-zzc)^2.,fbm_index5)
                    mean_fbm[*,*,ichan] = mean_fbm[*,*,ichan] + ( $
                                       fbm.fbm[*,*,fbm_index1] + $
                                       fbm.fbm[*,*,fbm_index2] + $
                                       fbm.fbm[*,*,fbm_index3] + $
                                       fbm.fbm[*,*,fbm_index4] + $
                                       fbm.fbm[*,*,fbm_index5])/5.*wght 
                 endif
              endfor
           endfor
        endfor
        mean_fbm[*,*,ichan]=mean_fbm[*,*,ichan]/rad
        ;;------------------------------------------------------------
        ;; map FBM on the energy and pitch grid of the weight function
        ;;------------------------------------------------------------
        mean_fbm2=fltarr(weights.nen,weights.npitch)
        for ie=0,weights.nen-1 do begin
           dummy=min(abs(fbm.energy-weights.energyarr[ie]),eindex)
           for ip=0,weights.npitch-1 do begin
              dummy=min(abs(fbm.pitch-weights.pitcharr[ip]),pindex)
              mean_fbm2[ie,ip]=mean_fbm[eindex,pindex,ichan]
              ;;[fast_ion/cm^3/dP/dE]
           endfor
        endfor
        ;;------------------------------------------------------------
        ;; ------ CALCULATE SYNTHETIC SPECTRA AND PROFIELES ----------
        ;;------------------------------------------------------------
        ;; PRODUCT with fast-ion distribution funciton
        prod=replicate(0.,weights.nen,weights.npitch)
        for ie=0,weights.nen-1 do begin
           for ip=0,weights.npitch-1 do begin
              prod[ie,ip]=mean_fbm2[ie,ip]*weights.weight_tot[ie,ip,ichan]
              ;;--> [ph/(s cm^2 dP keV)]
           endfor
        endfor
           flux[*,ichan] =total(prod,2)*weights.dpitch
  endfor ;; loop over channels	
END
