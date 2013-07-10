PRO augd_routines,inputs,grid,nbi,fida,profiles,equil,err

  restore,'/u/stagnerl/FIDASIM2/TEST/nbi_data.idl'
  restore,'/u/stagnerl/FIDASIM2/TEST/load_transp_profiles.idl'
  restore,'/u/stagnerl/FIDASIM2/TEST/load_bfield.idl'
  
  equil={rho_grid:rhotf,b:b,e:b*0}

  nbi_geometry_transp,nbgeom
;  help,nbgeom,/str
  nbi={einj:einj,pinj:pinj,full:ffull,half:fhalf,third:fthird,$
	   xyz_src:nbgeom.xyz_src,xyz_pos:nbgeom.xyz_pos,$
	   bmwidra:nbgeom.bmwidra,bmwidza:nbgeom.bmwidza,$
	   divy:nbgeom.divy,divz:nbgeom.divz,focy:nbgeom.focy,focz:nbgeom.focz}

  restore,'/u/stagnerl/FIDASIM2/TEST/fida_diag.idl'
  sigma_pi_ratio=0.5d0
  if inputs.shot gt 27500 then sigma_pi_ratio=0.9d0
  fida={sigma_pi_ratio:sigma_pi_ratio,nchan:det.nchan,xlos:det.xlos,ylos:det.ylos,$
		zlos:det.zlos,xhead:det.xhead,yhead:det.yhead,zhead:det.zhead,headsize:det.headsize}

 ; help, profiles,/str
  err=0
END