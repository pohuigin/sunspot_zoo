pro smart_fulldisk_alpha, metafile=metafile, fparam=fparam, pathimg=pathimg, pathdata=pathdata, savcutoutpath=savcutoutpath

dpathpngs=pathimg

mdiparams=ar_loadparam(fparam=fparam)

magdisplay=mdiparams.magthresh

;#I; I; A; [deg]; [asec]; [px]; A; A; [Mm^2]; F; [Mm^2]; [Mx]; F
;#SSZN; NOAA; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC
;000001;9313;27-Jan-2001 23:59:43.000;53,-7;777,-61;392.247,-30.7942;beta;eso;1.98E+04;-0.01;3.89E+03;2.59E+22;0.14

;Read the header of the meta file
readcol, metafile, metatxt, metavars, form='A,A', delim=';', count=50

;Determine the FOV box width in arcsecs
wboxpos=(where(strpos(metatxt,'BOXWIDTH') ne -1))[0]
boxwidth=metavars[wboxpos]

;Determine display dynamic range
wmagdisppos=(where(strpos(metatxt,'MAGDISPLAY') ne -1))[0]
magdisplay=metavars[wmagdisppos]

;Determine the conversion from arcsecs to pixels
wdxpos=(where(strpos(metatxt,'MAPDXDY') ne -1))[0]
dxdy=metavars[wdxpos]
dx=str_sep(dxdy,',')

readcol, metafile, sszn,noaa,date,hgpos,hcpos,pxpos,hale,zurich,area,areafrac,areathresh,flux,fluxfrac, delim=';',comment='#',form='A,A,A,A,A,A,A,A,A,A,A,A,A'

nar=n_elements(pxpos)
;spospx=strpos(pxpos,',')
xypx=fltarr(nar,2)
xyhc=fltarr(nar,2)

for i=0,nar-1 do begin

   restore,savcutoutpath+'ar_cutout_'+string(sszn[i],form='(I06)')+'.sav'


   xypx[i,*]=str_sep(pxpos[i],',')
   xyhc[i,*]=str_sep(hcpos[i],',')

   thisdate=time2file(date[i],/date)

   thismap=ar_readmag(pathdata+'mdi.fd_M_lev182.'+thisdate+'_000030_TAI.data.fits')

   imgsz=size(thismap.data,/dim)

   thisimg=dpathpngs+'ar_fulldisk_'+string(sszn[i],form='(I06)')
;      setplotenv,file=thisimg+'.eps',/ps,xs=12,ys=12
   plot_image,magscl(thismap.data,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,/iso,position=[0,0,1,1]
   draw_circle,imgsz[0]/2.,imgsz[1]/2.,thismap.rsun/thismap.dx,/data,color=255,thick=15

   plot_map,thismap,position=[0,0,1,1],xticklen=0.0001,yticklen=0.0001,/nodata,/noerase

stop

   dum=map_contour2xy(narmask, level=0.5, /data, /doplot, /over,color=!gray,thick=10)

; contour,narmask,xy_path,...
;oplot the contour, shift by the lwr left hand corner position of the box...

      vline,[xyhc[i,0]-boxwidth/2.,xyhc[i,0]+boxwidth/2.],yrange=[xyhc[i,1]-boxwidth/2.,xyhc[i,1]+boxwidth/2.],thick=15,color=255
      hline,[xyhc[i,1]-boxwidth/2.,xyhc[i,1]+boxwidth/2.],xrange=[xyhc[i,0]-boxwidth/2.,xyhc[i,0]+boxwidth/2.],thick=15,color=255

;      closeplotenv

stop
endfor










end
