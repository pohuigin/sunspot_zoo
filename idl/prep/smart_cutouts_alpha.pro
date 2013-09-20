;Script to generate a 10 image test data set
;Makes SMART cut-outs for 10 regions using the standard method
;(higgins et al. 2011)
;	Set A - pixels outside contour are zeroed, scaling is +-700
;       Set B - Pixels outside set to gaussian noise, same scaling 
;	...

pro smart_cutouts_alpha,skip1=skip1,skip2=skip2,skip3=skip3,skip4=skip4,skip5=skip5, $
                        dthresh=dthresh, $
                         pathfits=pathfits,pathpngs=pathpngs, $
                        inmetafile=inmetafile,outmetafile=outmetafile

dpathfits='~/science/projects/zooniverse/data_set/alpha/fits_jsoc/'
dpathpngs='~/science/projects/zooniverse/data_set/alpha/pngs/'
dpath='~/science/projects/zooniverse/data_set/alpha/'
noaapath='~/science/repositories/smart_library/noaa_srs/'
pngcutoutpath=dpath+'pngs_cutout/'
savcutoutpath=dpath+'sav_cutout/'
fmdi=file_search(dpathfits+'mdi*fits*')
nfile=n_elements(fmdi)

;Run version
runvers='ALPHA.0'

;Cut-out size for AR zooms
xycutsz=[600,600]

;Region grow distance using NAR centroid
nardist=50. ;in arc sec.

;Output meta data file
if n_elements(inmetafile) eq 0 then fcsvzoo=dpath+'smart_cutouts_metadata_alpha.txt' else fcsvzoo=inmetafile

;+/- Dynamic range for scaling the magnetograms 
if n_elements(dthresh) ne 1 then magdisplay=1000 else magdisplay=dthresh

;fpath='~/projects/zooniverse/science_gallery/images/'
;imgpath='~/projects/zooniverse/data_set/smart_set/'

;Initialise SunspotZoo numbering
nzoo=1l

;Get the SMART parameters
mdiparams=ar_loadparam(fparam='~/science/projects/zooniverse/data_set/ar_param_zooniverse.txt')

fits2map,fmdi[0],testmap

;Initialise CSV file for meta data
spawn,'echo "#Version: '+strtrim(runvers,2)+'" > '+fcsvzoo
spawn,'echo "#Sunspot Zoo Cut-out Meta Data" >> '+fcsvzoo
spawn,'echo "#Each numbered entry corresponds to an AR cut-out image with a filename that includes the number." >> '+fcsvzoo
spawn,'echo "#DATAID; '+strtrim(testmap.id,2)+'" >> '+fcsvzoo
spawn,'echo "#MAPDXDY [asec/px]; '+strjoin(strtrim([testmap.dx,testmap.dy],2),',')+'" >> '+fcsvzoo
spawn,'echo "#B0 [deg]; '+strtrim(testmap.b0,2)+'" >> '+fcsvzoo
spawn,'echo "#RSUN [asec]; '+strtrim(testmap.rsun,2)+'" >> '+fcsvzoo
spawn,'echo "#BOXWIDTH [asec]; '+strjoin(strtrim(xycutsz,2),',')+'" >> '+fcsvzoo
spawn,'echo "#MAGDISPLAY [G]; '+strtrim(magdisplay,2)+'" >> '+fcsvzoo
spawn,'echo "#MAGTHRESH [G]; '+strtrim(mdiparams.magthresh,2)+'" >> '+fcsvzoo
spawn,'echo "#SMOOTHTHRESH [G]; '+strtrim(mdiparams.smooththresh,2)+'" >> '+fcsvzoo
spawn,'echo "#" >> '+fcsvzoo
spawn,'echo "#I; I; A; [deg]; [asec]; [px]; A; A; [Mm^2]; F; [Mm^2]; [Mx]; F" >> '+fcsvzoo
spawn,'echo "#SSZN; NOAA; FILEDATE; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC" >> '+fcsvzoo


;Detect ARs in magnetograms
;fmdi=fsmart[wgood]
for i=0l,nfile-1l do begin
   thismap=ar_readmag(fmdi[i])
   maporig=thismap

   filedate=anytim(file2time(fmdi[i]),/vms)

   fdate=time2file(thismap.time,/date)
   fyyyy=strmid(fdate,0,4)

;stop

   thisarstr=ar_detect(thismap, /doprocess, mapproc=thisproc, params=mdiparams, doplot=doplot, status=status, cosmap=cosmap, limbmask=limbmask)

;Overwrite original data with processed
   thismap=thisproc

;Convert detection mask to all 1's and zeros...
   dmask=thisarstr.data
   w1=where(dmask ne 0)
   w0=where(dmask eq 0)
   dmask[w1]=1
   dmask[w0]=0
   thisarstr.data=dmask

;Get ARs for this date
   mmmotd_getarpos, narpos, inswpc=noaapath+fyyyy+'/'+fdate+'SRS.txt', /verb, /local
   nar=n_elements(narpos)



;For each NOAA region, pull out its X,Y position, make cut-out map,
;determine mag properties, write results into CSV file 

   for k=0l,nar-1l do begin
      rothel2xy, narpos[k].hgpos, narpos[k].date, thismap.time, hel_end, xy_start, xy_end
      smart_nsew2hg, strjoin(hel_end,''), thishglat, thishglon
      if xy_end[0] eq -9999 or xy_end[1] eq -9999 then xy_end=xy_start

      narmap=map_cutout(thismap, xycen=xy_end, xwidth=xycutsz[0], yheight=xycutsz[1], auxdat1=thisarstr.data, auxdat2=cosmap, outauxdat1=dsubmask, outauxdat2=dsubcos, auxdat3=limbmask, outauxdat3=dsublimb)

      dispmap=map_cutout(maporig, xycen=xy_end, xwidth=xycutsz[0], yheight=xycutsz[1],buffval=abs(mdiparams.nan))
      
      imgsz=size(narmap.data,/dim)

;Convert non-Zero pixels to 1 that are touching NAR position with radius of 50 arcsec.
      dnardist=dist(imgsz[0],imgsz[1])
      dnardist=shift(dnardist,imgsz[0]/2.,imgsz[1]/2.)
      wgood=where(dnardist le nardist/narmap.dx)
      wbad=where(dnardist gt nardist/narmap.dx)
      dnardist[wgood]=1
      dnardist[wbad]=0

      wgrownar=region_grow(dsubmask, where(dnardist eq 1),thresh=[0.5,1.5])
if wgrownar[0] eq -1 then continue
      dnardist[wgrownar]=1
      wnar=where((dnardist+dsubmask) eq 2.)
      dsubnarmask=fltarr(imgsz[0],imgsz[1])
      dsubnarmask[wnar]=1.

      narmask=narmap & narmask.data=dsubnarmask

      magpropstr=ar_magprop(map=narmap, mask=narmask, cosmap=dsubcos, params=mdiparams)
      areafrac=(magpropstr.posareabnd-magpropstr.negareabnd)/magpropstr.areabnd
      
;Enter meta data into CSV file
;SSZN; NOAA; FILEDATE; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC;
      spawn,'echo "'+string(nzoo,form='(I06)')+';'+strtrim(narpos[k].ars,2)+';'+strtrim(filedate,2)+';'+strtrim(narmap.time,2)+';'+strjoin(strtrim([thishglon,thishglat],2),',')+';'+strjoin(strtrim(xy_end,2),',')+';'+strjoin(strtrim(xy_end/[narmap.dx,narmap.dy],2),',')+';'+strjoin(narpos[k].hale,2)+';'+strjoin(narpos[k].mcintosh,2)+';'+strtrim(string(magpropstr.areabnd,form='(E15.2)'),2)+';'+strtrim(string(areafrac,form='(F15.2)'),2)+';'+strtrim(string(magpropstr.totarea,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.totflx,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.frcflx,form='(F15.2)'),2)+'" >> '+fcsvzoo

;stop
;Make cutout images
;      wnan=where(finite(dispmap.data) ne 1)
      datdisplay=dispmap.data*narmask.data
;      datdisplay[wnan]=mdiparams.nan

      wblanked=where(datdisplay eq 0)
      if wblanked[0] ne -1 then begin
         drand=randomn(seed,n_elements(wblanked))

         if narmap.interval eq 300 then drand=drand/max(drand)*mdiparams.magthresh/4. $
		else drand=drand/max(drand)*mdiparams.magthresh/2.
         datdisplay[wblanked]=drand
      endif

;     if wnan[0] ne -1 then datdisplay[wnan]=min(datdisplay)

wnan=where(dsublimb eq 0)
if wnan[0] ne -1 then datdisplay[wnan]=mdiparams.nan

      thisimg=pngcutoutpath+'ar_cutout_'+string(nzoo,form='(I06)')
      setplotenv,file=thisimg+'.eps',/ps,xs=12,ys=12
      plot_image,magscl(datdisplay,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,/iso,position=[0,0,1,1]
      draw_circle,-xy_end[0]/narmap.dx+imgsz[0]/2.,-xy_end[1]/narmap.dy+imgsz[1]/2.,narmap.rsun/narmap.dx,/data,color=255,thick=15

      closeplotenv

;      spawn,'convert -flatten -geometry '+strtrim(fix(imgsz[0]),2)+'x'+strtrim(fix(imgsz[1]),2)+' '+thisimg+'.eps '+thisimg+'.png'
;stop

      save,narmap,narmask,file=savcutoutpath+'ar_cutout_'+string(nzoo,form='(I06)')+'.sav',/comp

      nzoo=nzoo+1l
   endfor

   

;stop


endfor

outmetafile=fcsvzoo



return


stop

restore,dpath+'ar_cutout_stack.sav',/ver
imglist=[0,3,4,6,48,49,70,83,84,85,86,89,105,106,107] ;images to include in pairing
imgstack=imgstack[*,*,imglist]
imgstack[0,0,*]=-700 & imgstack[0,1,*]=700 ;so plot scaling looks correct
;pairs=make_pairs(n_elements(imglist)) ;make possible pair combinations

window,xs=800,ys=800
for i=0,n_elements(imglist)-1 do begin
	imga=imgstack[*,*,i]
	plot_image,imga>(-700)<700,position=[0,0,1,1], xthick=2, tit='', ytit='', xtit='', xtickname=strarr(10)+' ', ytickname=strarr(10)+' ',xticklen=0.001
	xyouts,0.01,0.94,strtrim(i,2),chars=5,charthick=2,/norm,color=0
;	xyouts,0.01,0.01,'A',chars=5,charthick=2,/norm,color=0
;	xyouts,0.51,0.01,'B',chars=5,charthick=2,/norm,color=0
	window_capture,file=imgpath+'img_'+string(i,form='(I03)'),/png
endfor

stop

end
