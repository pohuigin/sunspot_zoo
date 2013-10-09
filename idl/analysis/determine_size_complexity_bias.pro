;Determine whether larger ARs are more complex
;Plot the distribution of AR areas for each complexity class

pro determine_size_complexity_bias

dpath='~/science/projects/sunspot_zoo/data_set/all_clear/'

readcol,dpath+'smart_cutouts_metadata_allclear_20131001.txt',vSSZN, vNOAA, vN_NAR, vFILENAME, vDATE, vHGPOS, vHCPOS, vPXPOS, vHALE, vZURICH, vAREA, vAREAFRAC, vAREATHESH, vFLUX, vFLUXFRAC, 

;#SSZN; NOAA; N_NAR; FILENAME; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC
;000001;8809;1;20000101_1247_mdiB_1_8809.fits;1-Jan-2000 12:47:02.460;-8,-12;-143.63000,-164.23600;-72.510008,-82.912718;beta;bxo;3.44E+04;0.12;2.89E+03;2.18E+22;0.01

I

















end
