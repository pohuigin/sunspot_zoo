;Determine whether larger ARs are more complex
;Plot the distribution of AR areas for each complexity class

pro determine_size_complexity_bias

dpath='~/science/projects/sunspot_zoo/data_set/all_clear/'
ppath='~/science/projects/sunspot_zoo/results/'

readcol,dpath+'smart_cutouts_metadata_allclear_20131001.txt',vSSZN, vNOAA, vN_NAR, vFILENAME, vDATE, vHGPOS, vHCPOS, vPXPOS, vHALE, vZURICH, vAREA, vAREAFRAC, vAREATHESH, vFLUX, vFLUXFRAC, form='I,A,I,A,A,A,A,A,A,A,F,F,F,F,F',delim=';'

;#SSZN; NOAA; N_NAR; FILENAME; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC
;000001;8809;1;20000101_1247_mdiB_1_8809.fits;1-Jan-2000 12:47:02.460;-8,-12;-143.63000,-164.23600;-72.510008,-82.912718;beta;bxo;3.44E+04;0.12;2.89E+03;2.18E+22;0.01

wa=where(vHALE eq 'alpha')
wb=where(vHALE eq 'beta')

wg=where(vHALE eq 'gamma')
wgd=where(vHALE eq 'gamma-delta')

wd=where(vHALE eq 'delta')
wx=where(vHALE eq 'x')
wbgd=where(vHALE eq 'beta-gamma-delta')
wbg=where(vHALE eq 'beta-gamma')

;WA              LONG      = Array[1290]
;WB              LONG      = Array[2992]
;WG              LONG      =           -1
;WGD             LONG      =           -1
;WD              LONG      =           -1
;WX              LONG      = Array[28]
;WBGD            LONG      = Array[96]
;WBG             LONG      = Array[399]

;Alpha group: WA
waall=wa

;Beta group: WB
wball=wb

;Gamma group: WG
wgall=[wbgd,wbg]

;Get list of ARs for each Hale class

areathresha=vAREATHESH[waall]
areathreshb=vAREATHESH[wball]
areathreshg=vAREATHESH[wgall]
fluxa=vFLUX[waall]
fluxb=vFLUX[wball]
fluxg=vFLUX[wgall]
areaa=vAREA[waall]
areab=vAREA[wball]
areag=vAREA[wgall]

;Determine the Area distribution for each class

!p.multi=[0,1,3]
setcolors,/sys,/sil

plot_hist,areaa,bin=5000,chars=3,yran=yran,/ysty,xtit='AREA [Mm^2]',/xsty
plot_hist,areab,bin=5000,/oplot,color=!green
plot_hist,areag,bin=5000,/oplot,color=!red

plot_hist,areathresha,bin=500,chars=3,yran=yran,/ysty,xtit='Mag-Threshed AREA [Mm^2]',/xsty
plot_hist,areathreshb,bin=500,/oplot,color=!green
plot_hist,areathreshg,bin=500,/oplot,color=!red

plot_hist,fluxa,bin=5d21,chars=3,yran=yran,/ysty,xtit='Total Flux [Mx]',/xsty
plot_hist,fluxb,bin=5d21,/oplot,color=!green
plot_hist,fluxg,bin=5d21,/oplot,color=!red

window_capture,file=ppath+'determine_size_complexity_bias-hale_histograms_area_flux'

stop

yhistareaa=histogram(areaa,bin=5000,loc=xhistareaa)
yhistareab=histogram(areab,bin=5000,loc=xhistareab)
yhistareag=histogram(areag,bin=5000,loc=xhistareag)

yhistareathresha=histogram(areathresha,bin=500,loc=xhistareathresha)
yhistareathreshb=histogram(areathreshb,bin=500,loc=xhistareathreshb)
yhistareathreshg=histogram(areathreshg,bin=500,loc=xhistareathreshg)

yhistfluxa=histogram(fluxa,bin=5d21,loc=xhistfluxa)
yhistfluxb=histogram(fluxb,bin=5d21,loc=xhistfluxb)
yhistfluxg=histogram(fluxg,bin=5d21,loc=xhistfluxg)

plot,xhistareaa,yhistareaa,ps=10,/ylog,xtit='AREA [Mm^2]',/xsty,chars=3,yran=[1,1d3]
oplot,xhistareab,yhistareab,ps=10,color=!green
oplot,xhistareag,yhistareag,ps=10,color=!red

plot,xhistareathresha,yhistareathresha,ps=10,/ylog,xtit='Mag-Threshed AREA [Mm^2]',/xsty,chars=3,yran=[1,1d3]
oplot,xhistareathreshb,yhistareathreshb,ps=10,color=!green
oplot,xhistareathreshg,yhistareathreshg,ps=10,color=!red

plot,xhistfluxa,yhistfluxa,ps=10,/ylog,xtit='Total Flux [Mx]',/xsty,chars=3,yran=[1,1d3]
oplot,xhistfluxb,yhistfluxb,ps=10,color=!green
oplot,xhistfluxg,yhistfluxg,ps=10,color=!red

window_capture,file=ppath+'determine_size_complexity_bias-hale_histograms_area_flux_ylog'

stop

plot,xhistareaa,yhistareaa/max(float(yhistareaa)),ps=10,xtit='AREA [Mm^2]',/xsty,chars=3
oplot,xhistareab,yhistareab/max(float(yhistareab)),ps=10,color=!green
oplot,xhistareag,yhistareag/max(float(yhistareag)),ps=10,color=!red

plot,xhistareathresha,yhistareathresha/max(float(yhistareathresha)),ps=10,xtit='Mag-Threshed AREA [Mm^2]',/xsty,chars=3
oplot,xhistareathreshb,yhistareathreshb/max(float(yhistareathreshb)),ps=10,color=!green
oplot,xhistareathreshg,yhistareathreshg/max(float(yhistareathreshg)),ps=10,color=!red

plot,xhistfluxa,yhistfluxa/max(float(yhistfluxa)),ps=10,xtit='Total Flux [Mx]',/xsty,chars=3
oplot,xhistfluxb,yhistfluxb/max(float(yhistfluxb)),ps=10,color=!green
oplot,xhistfluxg,yhistfluxg/max(float(yhistfluxg)),ps=10,color=!red

window_capture,file=ppath+'determine_size_complexity_bias-hale_histograms_area_flux_norm'

stop

;Try with McIntosh?



stop









end
