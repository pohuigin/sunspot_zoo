;Script to generate Beta test image data set
;Makes SMART cut-outs for 10 regions using the standard method
;(higgins et al. 2011)
;	Set A - pixels outside contour are zeroed, scaling is +-1000
;       Set B - Pixels outside set to gaussian noise, same scaling 
;	...

pro smart_cutouts_allclear,skip1=skip1,skip2=skip2,skip3=skip3,skip4=skip4,skip5=skip5, $
                        dthresh=dthresh, $
                         pathfits=pathfits,pathpngs=pathpngs, fparam=fparam, $
                        inmetafile=inmetafile,outmetafile=outmetafile, $
                           debug=debug,iinit=iinit

if keyword_set(debug) then debug=1 else debug=0

dpathfits='~/science/projects/sunspot_zoo/data_set/all_clear/nwra_fits/'
dpathpngs='~/science/projects/sunspot_zoo/data_set/all_clear/pngs/'
dpathmeta='~/science/projects/sunspot_zoo/data_set/all_clear/nwra_meta/'
dpath='~/science/projects/sunspot_zoo/data_set/all_clear/'
noaapath='~/science/repositories/smart_library/noaa_srs/'
pngcutoutpath=dpath+'pngs_cutout/'
savcutoutpath=dpath+'sav_cutout/'

yrarr=['2000','2001','2002','2003','2004','2005']
nyr=n_elements(yrarr)

fmdi=''
yesnoc1=-1
yesnom1=-1
yesnom5=-1
noaaall=''
fnameslist=''
for k=0,nyr-1 do begin

   readcol,dpathmeta+'eventsC1_24hr'+yrarr[k]+'.txt',dum,thisc1,delim=',',form='A,A'
   readcol,dpathmeta+'eventsM1_12hr'+yrarr[k]+'.txt',dum,thism1,delim=',',form='A,A'
   readcol,dpathmeta+'eventsM5_12hr'+yrarr[k]+'.txt',dum,thism5,delim=',',form='A,A'
   readcol,dpathmeta+'fileSpecs'+yrarr[k]+'.txt',thisspecs,delim='$#',form='A'

   thisnoaaall=strmid(thisspecs,51,100)
   thisfnames=strmid(thisspecs,0,30)

   yesnoc1=[yesnoc1,thisc1]
   yesnom1=[yesnom1,thism1]
   yesnom5=[yesnom5,thism5]
   noaaall=[noaaall,strtrim(thisnoaaall,2)]
   fnameslist=[fnameslist,strtrim(thisfnames,2)]

   fmdi=[fmdi,file_search(dpathfits+yrarr[k]+'/'+'*fits*')]

endfor

fmdi=fmdi[1:*]
nfile=n_elements(fmdi)

yesnoc1=yesnoc1[1:*]
yesnom1=yesnom1[1:*]
yesnom5=yesnom5[1:*]
noaaall=noaaall[1:*]
fnameslist=fnameslist[1:*]

;Run version
runvers='BETA.1.'+time2file(systim(/utc))

;Buffer size for AR cutouts
buffval=-9999.
xbuff=410
ybuff=330



;Region grow distance using NAR centroid
;nardist=50. ;in arc sec.

;Output meta data file
if n_elements(inmetafile) eq 0 then fcsvzoo=dpath+'smart_cutouts_metadata_'+strlowcase(runvers)+'.txt' else fcsvzoo=inmetafile

;+/- Dynamic range for scaling the magnetograms 
if n_elements(dthresh) ne 1 then magdisplay=1000 else magdisplay=dthresh

;fpath='~/projects/zooniverse/science_gallery/images/'
;imgpath='~/projects/zooniverse/data_set/smart_set/'

;Initialise SunspotZoo numbering
nzoo=1l

;Get the SMART parameters
if n_elements(fparam) ne 1 then fparam='~/science/projects/sunspot_zoo/data_set/ar_param_zooniverse.txt'
mdiparams=ar_loadparam(fparam=fparam)

fits2map,fmdi[0],testmap

;Initialise CSV file for meta data
spawn,'echo "#Version: '+strtrim(runvers,2)+'" > '+fcsvzoo,/sh
spawn,'echo "#Sunspot Zoo Cut-out Meta Data" >> '+fcsvzoo,/sh
spawn,'echo "#Each numbered entry corresponds to an AR cut-out image with a filename that includes the number." >> '+fcsvzoo,/sh
spawn,'echo "#DATAID; '+strtrim(testmap.id,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#MAPDXDY [asec/px]; '+strjoin(strtrim([testmap.dx,testmap.dy],2),',')+'" >> '+fcsvzoo,/sh
spawn,'echo "#B0 [deg]; '+strtrim(testmap.b0,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#RSUN [asec]; '+strtrim(testmap.rsun,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#BOXWIDTH [asec]; '+strjoin(strtrim([xbuff,ybuff],2),',')+'" >> '+fcsvzoo,/sh
spawn,'echo "#MAGDISPLAY [G]; '+strtrim(magdisplay,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#MAGTHRESH [G]; '+strtrim(mdiparams.magthresh,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#SMOOTHTHRESH [G]; '+strtrim(mdiparams.smooththresh,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#" >> '+fcsvzoo,/sh
spawn,'echo "#Units:" >> '+fcsvzoo,/sh
spawn,'echo "#--; --; [number]; --; --; [deg]; [asec]; [px]; --; --; [Mm^2]; [fraction]; [Mm^2]; [Mx]; [fraction]; [deg]; [binary]; [binary]; [binary]; [list];" >> '+fcsvzoo,/sh
spawn,'echo "#FORMAT; I,I,I,A,A,A,A,A,A,A,F,F,F,F,F,F,I,I,I,A" >> '+fcsvzoo,/sh
spawn,'echo "#SSZN; NOAA; N_NAR; FILENAME; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC; BIPOLESEP; C1FLR24HR; M1FLR12HR; M5FLR12HR; ALLNOAA; " >> '+fcsvzoo,/sh

;Loop through each cut-out fits file

if n_elements(iinit) ne 1 then iinit=0l else iinit=long(iinit)

;fmdi=fsmart[wgood]
for i=iinit,nfile-1l do begin
   if file_exist(fmdi[i]) ne 1 then continue

   thismap=ar_readmag(fmdi[i],/mread)

   maporig=thismap

   filedate=anytim(file2time(fmdi[i]),/vms)

   fdate=time2file(thismap.time,/date)
   fyyyy=strmid(fdate,0,4)

;Buffer the map with noise so that we can expand the FOV
   thismap=map_buffer_2d(thismap,value=buffval,xs=xbuff,ys=ybuff)

;Remake the WCS to fit the new buffered map
   map2wcs,thismap,bwcs
   add_prop,thismap,wcs=bwcs,/replace

;AR detection is being run, but the detection mask is not being used
;at the moment... not sure whether to show people everything in the
;FOV or only stuff within SMART boundaries...

   thisarstr=ar_detect(thismap, /doprocess, mapproc=thisproc, params=mdiparams, fparam=fparam, doplot=doplot, status=status, cosmap=cosmap, limbmask=limbmask)


;Buffer the cosmap and limbmask
;cosmap=buffer_2d(cosmap,value=buffval,xs=xbuff,ys=ybuff)
;limbmask=buffer_2d(limbmask,value=buffval,xs=xbuff,ys=ybuff)
;UNNECESSARY NOW!!!!!

;Overwrite original data with processed
;   thismap=thisproc

;Convert detection mask to all 1's and zeros...
;   dmask=thisarstr.data
;   w1=where(dmask ne 0)
;   w0=where(dmask eq 0)
;   dmask[w1]=1
;   dmask[w0]=0
;   thisarstr.data=dmask

;Get ARs for this date
;   mmmotd_getarpos, narpos, inswpc=noaapath+fyyyy+'/'+fdate+'SRS.txt', /verb, /local
;   nar=n_elements(narpos)



;For each NOAA region, pull out its X,Y position, make cut-out map,
;determine mag properties, write results into CSV file 

;   for k=0l,nar-1l do begin
;      rothel2xy, narpos[k].hgpos, narpos[k].date, thismap.time, hel_end, xy_start, xy_end
;      smart_nsew2hg, strjoin(hel_end,''), thishglat, thishglon
;      if xy_end[0] eq -9999 or xy_end[1] eq -9999 then xy_end=xy_start

;      narmap=map_cutout(thismap, xycen=xy_end, xwidth=xycutsz[0], yheight=xycutsz[1], auxdat1=thisarstr.data, auxdat2=cosmap, outauxdat1=dsubmask, outauxdat2=dsubcos, auxdat3=limbmask, outauxdat3=dsublimb)

;      dispmap=map_cutout(maporig, xycen=xy_end, xwidth=xycutsz[0], yheight=xycutsz[1],buffval=abs(mdiparams.nan))
      dispmap=maporig
      dispmap=map_buffer_2d(dispmap,val=buffval,xs=xbuff,ys=ybuff)

      narmap=thisproc

      imgsz=size(narmap.data,/dim)
      
;window,xs=imgsz[0],ys=imgsz[1]

;Convert non-Zero pixels to 1 that are touching NAR position with radius of 50 arcsec.
;      dnardist=dist(imgsz[0],imgsz[1])
;      dnardist=shift(dnardist,imgsz[0]/2.,imgsz[1]/2.)
;      wgood=where(dnardist le nardist/narmap.dx)
;      wbad=where(dnardist gt nardist/narmap.dx)
;      dnardist[wgood]=1
;      dnardist[wbad]=0

;      wgrownar=region_grow(dsubmask, where(dnardist eq 1),thresh=[0.5,1.5])
;if wgrownar[0] eq -1 then continue
;      dnardist[wgrownar]=1
;      wnar=where((dnardist+dsubmask) eq 2.)
;      dsubnarmask=fltarr(imgsz[0],imgsz[1])
;      dsubnarmask[wnar]=1.

;Calculate mag properties for the whole FOV (not using detections currently)
      narmask=maporig
      origsz=size(maporig.data,/dim)
      narmask.data=fltarr(origsz[0],origsz[1])+1.
      narmask=map_buffer_2d(narmask,value=0.1,xs=xbuff,ys=ybuff)

      magpropstr=ar_magprop(map=narmap, mask=narmask, cosmap=cosmap, params=mdiparams)
      areafrac=(magpropstr.posareabnd-magpropstr.negareabnd)/magpropstr.areabnd

;Process mag. for determining positions (get rid of noise, get rid of spikes, NaNs, then do cosine)
      narposmap=ar_processmag(thismap,/nocosine,/nofilt, params=mdiparams)
      narposdat=narposmap.data
      wthreshpos=where(narposdat ge -mdiparams.MDI_NOISETHRESH and narposdat le mdiparams.MDI_NOISETHRESH)
      if wthreshpos[0] ne -1 then narposdat[wthreshpos]=0
      narposmap.data=narposdat*cosmap
      narposmask=narmask & narposmask.data=round(narposmask.data)

;Determine NAR position structure
      pospropstr=ar_posprop(map=narposmap, mask=narposmask, cosmap=cosmap, params=mdiparams, outpos=pospropstrpos, outneg=pospropstrneg, status=posstatus)

xy_cen=[pospropstr.XCENFLX,pospropstr.YCENFLX]
hc_cen=[pospropstr.HCXFLX,pospropstr.HCYFLX]
hg_cen=[pospropstr.HGLONFLX,pospropstr.HGLATFLX]

;xy_end=[narmap.index.crpix1,narmap.index.crpix2]
;hc_pos=[narmap.index.crval1,narmap.index.crval2]
;hglocstr=arcmin2hel(hc_pos[0]/60.,hc_pos[1]/60.,date=narmap.time)
;hglat=hglocstr[0]
;hglon=hglocstr[1]
;smart_nsew2hg, hglocstr, hglat, hglon

;Determine the bipole separation distance
if posstatus eq 1 or posstatus eq 2 or posstatus eq 3 then bipolesep=-1 else $
   bipolesep=gc_dist([pospropstrpos.HGLONFLX,pospropstrpos.HGLATFLX],[pospropstrneg.HGLONFLX,pospropstrneg.HGLATFLX])

n_noaa=narmap.index.N_NOAA
noaanum=narmap.index.NOAA_0
hale=strlowcase(narmap.index.HALE_0)
mcint=strlowcase(narmap.index.MCINT_0)

if hale eq '' then hale = 'none'
if mcint eq '' then mcint = 'none'

if debug then begin

   help,magpropstr,/str

   loadct,0
   plot_map,narposmap,dran=[-500,500],/limb,l_color=255,grid=10
   setcolors,/sys,/sil
   xyouts,'0.02','0.02','hgpos = '+strjoin(strtrim(hg_cen,2),','),color=!white,chars=2,/norm
   xyouts,'0.02','0.06','bipole = '+strjoin(strtrim(bipolesep,2),','),color=!white,chars=2,/norm
   plots,hc_cen[0],hc_cen[1],ps=4,color=!orange
   plots,pospropstrpos.hcxFLX,pospropstrpos.HcyFLX,ps=4,color=!red
   plots,pospropstrneg.hcxFLX,pospropstrneg.HcyFLX,ps=4,color=!green

stop

endif

filename=(reverse(str_sep(fmdi[i],'/')))[0]

;Get region meta info (yes/no flare, all noaa nums, file name list)

wthisfile=where(fnameslist eq filename)

if n_elements(wthisfile) ne 1 or wthisfile[0] eq -1 then begin
   thisc1='-1'
   thism1='-1'
   thism5='-1'
   thisnoaaall='-1'
endif else begin
   thisc1=yesnoc1[wthisfile]
   thism1=yesnom1[wthisfile]
   thism5=yesnom5[wthisfile]
   thisnoaaall=noaaall[wthisfile]
endelse

;check for AR complexes with Hale classes
;if noaanum gt 1 and hale eq 'beta' then hale='gamma'
;if noaanum gt 1 and hale eq 'alpha' then hale='gamma'

;Enter meta data into CSV file
;SSZN; NOAA; N_NAR; FILEDATE; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC; BIPOLESEP;C1FLR24HR; M1FLR12HR; M5FLR12HR; ALLNOAA;
;      spawn,'echo "'+string(nzoo,form='(I06)')+';'+strtrim(noaanum,2)+';'+strtrim(n_noaa,2)+';'+strtrim(filename,2)+';'+strtrim(narmap.time,2)+';'+strjoin(strtrim([hglon,hglat],2),',')+';'+strjoin(strtrim(xy_end,2),',')+';'+strjoin(strtrim(xy_end/[narmap.dx,narmap.dy],2),',')+';'+strtrim(hale,2)+';'+strtrim(mcint,2)+';'+strtrim(string(magpropstr.areabnd,form='(E15.2)'),2)+';'+strtrim(string(areafrac,form='(F15.2)'),2)+';'+strtrim(string(magpropstr.totarea,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.totflx,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.frcflx,form='(F15.2)'),2)+'" >> '+fcsvzoo
      spawn,'echo "'+string(nzoo,form='(I06)')+';'+strtrim(noaanum,2)+';'+strtrim(n_noaa,2)+';'+strtrim(filename,2)+';'+strtrim(narmap.time,2)+';'+strjoin(strtrim(hg_cen,2),',')+';'+strjoin(strtrim(hc_cen,2),',')+';'+strjoin(strtrim(xy_cen,2),',')+';'+strtrim(hale,2)+';'+strtrim(mcint,2)+';'+strtrim(string(magpropstr.areabnd,form='(E15.2)'),2)+';'+strtrim(string(areafrac,form='(F15.2)'),2)+';'+strtrim(string(magpropstr.totarea,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.totflx,form='(E15.2)'),2)+';'+strtrim(string(magpropstr.frcflx,form='(F15.2)'),2)+';'+strtrim(string(bipolesep,form='(F15.2)'),2)+';'+strtrim(thisc1,2)+';'+strtrim(thism1,2)+';'+strtrim(thism5,2)+';'+strtrim(thisnoaaall,2)+'" >> '+fcsvzoo

;stop

;Make cutout images
;      wnan=where(finite(dispmap.data) ne 1)
      woff=where(limbmask ne 1)
      datdisplay=dispmap.data ;*narmask.data
;      datdisplay[wnan]=mdiparams.nan

      wblanked=where(datdisplay eq 0 or datdisplay eq buffval)
      if wblanked[0] ne -1 then begin
         drand=randomn(seed,n_elements(wblanked))

         if narmap.index.interval eq 300 then drand=drand/max(drand)*mdiparams.magthresh/4. $
		else drand=drand/max(drand)*mdiparams.magthresh/2.
         datdisplay[wblanked]=drand
      endif

;     if wnan[0] ne -1 then datdisplay[wnan]=min(datdisplay)

;stop

wnan=where(limbmask eq 0)
if wnan[0] ne -1 then datdisplay[wnan]=mdiparams.nan
if woff[0] ne -1 then datdisplay[woff]=mdiparams.nan

      thisimg=pngcutoutpath+'ar_cutout_'+string(nzoo,form='(I06)')

      setplotenv,file=thisimg+'.eps',/ps,xs=5,ys=5*imgsz[1]/float(imgsz[0])

      plot_image,magscl(datdisplay,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
      plot_map,dispmap,xticklen=0.0001,yticklen=0.0001,color=0,position=[0,0,1,1],/nodata,/noerase,thick=30
      ;draw_circle,-xy_end[0]/narmap.dx+imgsz[0]/2.,-xy_end[1]/narmap.dy+imgsz[1]/2.,narmap.rsun/narmap.dx,/data,color=255,thick=15
      draw_circle,0,0,narmap.rsun,/data,color=255,thick=20

      closeplotenv

;      spawn,'convert -flatten -geometry '+strtrim(fix(imgsz[0]),2)+'x'+strtrim(fix(imgsz[1]),2)+' '+thisimg+'.eps '+thisimg+'.png'
;stop

;      save,narmap,narmask,file=savcutoutpath+'ar_cutout_'+string(nzoo,form='(I06)')+'.sav',/comp

      nzoo=nzoo+1l
;   endfor

   

;stop
;TEMP!!!!!!!!!!!!!!!!!!!
;if i ge 50 then stop

endfor

outmetafile=fcsvzoo



stop

end
