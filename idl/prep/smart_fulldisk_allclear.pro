pro smart_fulldisk_allclear, metafile=metafile, fparam=fparam, pathimg=pathimg, pathdata=pathdata, savcutoutpath=savcutoutpath, params=inparams

dpathpngs=pathimg

;Determine path to MDI files
spawn,'echo $MDI_MAGS_LOCAL', mdimaglocal,/sh

if data_type(inparams) eq 8 then mdiparams=inparams $
   else mdiparams=ar_loadparam(fparam=fparam)

magdisplay=mdiparams.magthresh

;#I; I; A; [deg]; [asec]; [px]; A; A; [Mm^2]; F; [Mm^2]; [Mx]; F
;#SSZN; NOAA; N_NAR; FILENAME; DATE; HGPOS; HCPOS; PXPOS; HALE; ZURICH; AREA; AREAFRAC; AREATHESH; FLUX; FLUXFRAC
;000001;8809;1;20000101_1247_mdiB_1_8809.fits;1-Jan-2000 12:47:02.460;-8,-12;-143.63000,-164.23600;-72.510008,-82.912718;beta;bxo;3.44E+04;0.12;2.89E+03;2.18E+22;0.01

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

;readcol, metafile, sszn,noaa,n_nar,nwrafile,date,hgpos,hcpos,pxpos,hale,zurich,area,areafrac,areathresh,flux,fluxfrac, delim=';',comment='#',form='A,A,A,A,A,A,A,A,A,A,A,A,A,A'
readcol, metafile, sszn,noaa,n_nar,nwrafile,date, delim=';',comment='#',form='A,A,A,A,A'

nar=n_elements(sszn)
;spospx=strpos(pxpos,',')
;xypx=fltarr(nar,2)
;xyhc=fltarr(nar,2)

;stop

;TEMP!!!!!!!
;window,xs=700,ys=700

for i=0,nar-1 do begin

   thisnwra=nwrafile[i]

;Determine date
   yyyy=strmid(thisnwra,0,4)
   mm=strmid(thisnwra,4,2)

;READ NWRA CUTOUT FILE
   cutmap=ar_readmag(pathdata+'/'+yyyy+'/'+thisnwra)


;Determine month and filename of MDI file
;path to MDI fits file
   fmdi=mdimaglocal+'/m'+yyyy+mm+'/'+'fdmg'+strmid(thisnwra,0,13)+'.fts'

;Read in the MDI file
   fexist=file_exist(fmdi)
   if fexist ne 1 then begin
      print,'MDI file missing! Searching for closest match...'
      mdilist=file_search(mdimaglocal+'/m'+yyyy+mm+'/*.fts')


      mditims=anytim(file2time(mdilist))
      nwratim=anytim(file2time(thisnwra))
      wbestmdi=where(abs(mditims-nwratim) eq min(abs(mditims-nwratim)))
      fmdi=mdilist[wbestmdi]

;stop
   endif

;   restore,savcutoutpath+'ar_cutout_'+string(sszn[i],form='(I06)')+'.sav'


;   xypx[i,*]=str_sep(pxpos[i],',')
;   xyhc[i,*]=str_sep(hcpos[i],',')
;   thisdate=time2file(date[i],/date)

   thismdimap=ar_readmag(fmdi)

;stop



;Create cutout mask using NWRA map
   cutsz=size(cutmap.data,/dim)
   cutmask=fltarr(cutsz[0],cutsz[1])
   cutmask[where(cutmap.data ne 0)]=1
   cutmaskmap=cutmap
   cutmaskmap.data=cutmask
   cutmaskmap=map_buffer_2d(cutmaskmap,xs=500,ys=500,val=0)

;   plot_map,thismdimap,dran=[-500,500]

;   plot_map,cutmaskmap,/over,level=[0.5,0.6],c_color=255







   imgsz=size(thismdimap.data,/dim)

   thisimg=dpathpngs+'ar_fulldisk_'+string(sszn[i],form='(I06)')
   setplotenv,file=thisimg+'.eps',/ps,xs=12,ys=12

   loadct,0,/silent
   plot_image,magscl(thismdimap.data,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1]
   draw_circle,imgsz[0]/2.,imgsz[1]/2.,thismdimap.rsun/thismdimap.dx,/data,color=255,thick=15

   plot_map,thismdimap,position=[0,0,1,1],xticklen=0.0001,yticklen=0.0001,/nodata,/noerase

   setcolors,/sys,/sil
;   dum=map_contour2xy(narmask, level=0.5, /data, /doplot, /over,color=!gray,thick=10)
   plot_map,cutmaskmap,level=[0.5,0.6],color=255,/over,c_thick=5

; contour,narmask,xy_path,...
;oplot the contour, shift by the lwr left hand corner position of the box...

;      vline,[xyhc[i,0]-boxwidth/2.,xyhc[i,0]+boxwidth/2.],yrange=[xyhc[i,1]-boxwidth/2.,xyhc[i,1]+boxwidth/2.],thick=15,color=255
;      hline,[xyhc[i,1]-boxwidth/2.,xyhc[i,1]+boxwidth/2.],xrange=[xyhc[i,0]-boxwidth/2.,xyhc[i,0]+boxwidth/2.],thick=15,color=255


      closeplotenv

;stop
endfor










end
