;Determine the maximum size of All-Clear cutouts so that a proper
;buffer can be chosen to prep the images 

pro test_allclear_cutout_size,skip1=skip1,skip2=skip2,skip3=skip3,skip4=skip4,skip5=skip5, $
                        dthresh=dthresh, $
                         pathfits=pathfits,pathpngs=pathpngs, fparam=fparam, $
                        inmetafile=inmetafile,outmetafile=outmetafile

dpathfits='~/science/projects/sunspot_zoo/data_set/all_clear/nwra_fits/'
dpathpngs='~/science/projects/sunspot_zoo/data_set/all_clear/pngs/'
dpath='~/science/projects/sunspot_zoo/data_set/all_clear/'
noaapath='~/science/repositories/smart_library/noaa_srs/'
pngcutoutpath=dpath+'pngs_cutout/'
savcutoutpath=dpath+'sav_cutout/'

yrarr=['2000','2001','2002','2003','2004','2005']
nyr=n_elements(yrarr)

fmdi=''
for k=0,nyr-1 do fmdi=[fmdi,file_search(dpathfits+yrarr[k]+'/'+'*fits*')]
fmdi=fmdi[1:*]
nfile=n_elements(fmdi)

naxisarr=fltarr(nfile,2)
for i=0,nfile-1 do begin
   mreadfits,fmdi[i],ind,/nodata
   naxisarr[i,0]=ind.naxis1
   naxisarr[i,1]=ind.naxis2
   
endfor

print,'max x',max(naxisarr[*,0])
print,'max y',max(naxisarr[*,1])

plot,naxisarr[*,0],naxisarr[*,1],ps=4,ytit='All-clear Cutout Y-dimensions',xtit='All-clear Cutout X-dimensions',chars=2
setcolors,/sys,/sil
hline,300,color=!red
hline,329,color=!red
vline,300,color=!red
vline,410,color=!red
window_capture,file='test_allclear_cutout_size',/png

stop

end
