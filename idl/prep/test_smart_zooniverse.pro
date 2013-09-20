goto,jump_run_cutouts
if not keyword_set(skip1) then begin

;Pull out SMART detection info and data meta info

   mreadfits, fsmart,indarr,datarr

   nind=n_elements(indarr)

   for i=0,nind-1 do begin
;   index2map,indarr[i],datarr[*,*,i],map
      map=ar_readmag(fsmart[i])

      if n_elements(maparr) eq 0 then maparr=map else maparr=[maparr,map]
   endfor


   cosmap=ar_cosmap(maparr[0], rrdeg=rrdegmap, wcs=wcsmap, offlimb=offlimbmap, edgefudge=0.25,outcoord=coord)
;wcs_convert_to_coord, wcs, hgcoord, 'HG'
   WCS_CONV_HPC_HG, reform(coord[0,*,*]), reform(coord[1,*,*]), hglon, hglat,ang_units='arcseconds'
   hgcoord=[[[hglon]],[[hglat]]]

   maxarr=fltarr(nind)
   medarr=fltarr(nind)
   meanarr=fltarr(nind)
   for i=0,nind-1 do begin

      datarr[*,*,i]=datarr[*,*,i]*cosmap

;   wmid=where(rrdegmap lt 20)
      wmid=where(hglon gt -60 and  hglon lt 60 and $
                 hglat gt -5 and  hglat lt 5)

      thisarr=abs((datarr[*,*,i])[wmid])

      maxarr[i]=max(thisarr)
      medarr[i]=median(thisarr)
      meanarr[i]=mean(thisarr)

;plot_image,magscl(datarr[*,*,i])
;contour,hglon,level=[-60,60],c_color=255,/over
;contour,hglat,level=[-5,5],c_color=255,/over
;stop

   endfor

;not exposure actually- its the averaging over time of multiple magnetograms
   exptime=indarr.interval

;Only take 5min avged data
   wgood=where(exptime ge 300)

   save,maxarr,medarr,meanarr,exptime,wgood,file=dpath+'mdi_mom'

endif else restore,dpath+'mdi_mom'
jump_run_cutouts:
