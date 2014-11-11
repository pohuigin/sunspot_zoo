;Script to generate Beta test image data set
;Makes SMART cut-outs for 10 regions using the standard method
;(higgins et al. 2011)
;	Set A - pixels outside contour are zeroed, scaling is +-1000
;       Set B - Pixels outside set to gaussian noise, same scaling 
;	...

;----------------------------------------------------------------------------->
;make a YYYYMM directory within a root path
;path = the root path
;yyyymm = the date directory to be created
;outpath = the path that was created (or not created)

pro smart_cutouts_smart2_mkdirym, inpath, inyyyymm, outpath
path=inpath
yyyymm=strtrim(inyyyymm,2)

doadd=0
nadd=0
addpath=''

ympos=strpos(path,'YYYYMM')
if ympos ne -1 then begin
	patharr=str_sep(path,'/')
	npath=n_elements(patharr)
	wins=where(patharr eq 'YYYYMM')

	if wins gt 0 then prepaths=patharr[0:wins-1]

	if wins lt npath-1 then begin
		addpath=patharr[wins+1:*]
		wadd=where(addpath ne '')
		if wadd[0] ne -1 then begin
			addpath=addpath[wadd]
			nadd=n_elements(addpath)
			doadd=1
		endif
	endif
	
	STRPUT, path, yyyymm, ympos

	if not file_exist(strjoin(prepaths,'/')+'/'+yyyymm) then spawn,'mkdir '+strjoin(prepaths,'/')+'/'+yyyymm,/sh

endif else begin
	path=path+'/'+yyyymm

	if not file_exist(path) then spawn,'mkdir '+path,/sh

endelse

outpath=path

if doadd then begin
	for m=0,nadd-1 do begin
		if not file_exist(strjoin(prepaths,'/')+'/'+yyyymm+'/'+addpath[m]) then spawn,'mkdir '+strjoin(prepaths,'/')+'/'+yyyymm+'/'+addpath[m],/sh
	endfor
endif

;stop

end

;----------------------------------------------------------------------------->

pro smart_cutouts_smart2,res1tore=res1tore,fparam=fparam,debug=debug,iinit=iniinit, nzooinit=nzooinit, runvers=inrunvers, $
						pathroot=dpath, $					;root path to /dataset/smart2 for this Sunspotter data run
						pathdataarch=pathdataarch, $		;path to archived zooniverse data in ~/science/data/processed/zooniverse/smart2/YYYYMM/
						pathprojimg=pathproj, $				;output path to projected cutout EPS files
						pathcutoutimg=dpathpngs, $			;output path to cutout EPS files
						pathprojfits=pathprojfits, $		;output path to projected cutout fits files
						pathcutoutfits=pathcutoutfits, $	;output path to cutout fits files
						pathfulldiskimg=pathfulldiskimg, $	;output path to full disk images
						pathmeta=dpathmeta, $				;path to input meta file directory for this run
						pathmasksin=dpathmask, $			;input detection masks
						pathmdidata=dpathfits, $			;MDI data path
						fmetamagin=fcsvdetect, $			;SMART2 magnetogram meta file
						fmetaarin=fcsvar, $					;SMART2 AR detection meta file
						fmetaout=outmetafile				;output meta file 
                           

;Set some parameters
;Run version
if not keyword_set(inrunvers) then runvers='GAMMA.1.'+time2file(systim(/utc)) else runvers=inrunvers

;Buffer size for AR cutouts
buffval=-9999.
xbuff=500
ybuff=400


if keyword_set(debug) then debug=1 else debug=0



;Read in the detection CSV files 

strdetect=read_data_file(fcsvdetect)
strar=read_data_file(fcsvar)

;Magnetic property file doesn't exist for this data... yet
;fcsvarprop=pathmeta+'smart2_core_magprop_19960415_20100815_run1.0.combined_ar.txt'
;strprop=read_data_file(fcsvarprop)


;--------------------------------------------------------->

;Match the prop structure elements to the ar detection structure elements
;match,strar.DATAFILE+'_'+strtrim(strar.arid,2),strprop.DATAFILE+'_'+strtrim(strprop.arid,2),msubdet,msubpos

;ONLY take elements with match in each array
;strar=strar[msubdet]
;strprop=strprop[msubpos]

;--------------------------------------------------------->

if not keyword_set(res1tore) then begin ;-!!!!!!!!!!!!!!!->

;Match the magneogram structure elements to the detection elements

;make uniq list of data files in AR structure  array 

sdatfile=sort(strar.DATAFILE)
ardatfile=strar[sdatfile].DATAFILE
ardatfile=ardatfile[uniq(ardatfile)]
ndatfile=n_elements(ardatfile)
nars=n_elements(strar)

ar_file_struct=ar_struct_init(structid='ar_chk_core')
ar_file_struct=replicate(ar_file_struct,nars)

;MATCH THE MAG STRUCT TO THE PROP STRUCT SO I CAN PLOT PROPS VS TIME!!!!
;loop over uniq data files in AR struct, rather than the data file structure itself, 
;because not all magnetograms will have an AR in them.

for i=0l,ndatfile-1l do begin
	wthisar=where(strar.DATAFILE eq ardatfile[i])
	
	wthisdat=(where(strdetect.DATAFILE eq ardatfile[i]))[0]

	ar_file_struct[wthisar]=strdetect[wthisdat]

endfor

save,ar_file_struct,file=dpath+'smart_cutouts_smart2_res1tore.sav'
endif else restore, dpath+'smart_cutouts_smart2_res1tore.sav',/ver
;-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!->

;----------------------------------------------------------------------------->



;Output meta data file
if n_elements(outmetafile) eq 0 then fcsvzoo=dpath+'smart2_cutouts_metadata_'+strlowcase(runvers)+'.txt' else fcsvzoo=outmetafile

;+/- Dynamic range for scaling the magnetograms 
magdisplay=1000.

;Get the SMART parameters
if n_elements(fparam) ne 1 then fparam='~/science/projects/sunspot_zoo/data_set/ar_param_zooniverse.txt'
params=ar_loadparam(fparam=fparam)

mreadfits,dpathmask+'/'+strmid(time2file(file2time(ar_file_struct[0].maskfile)),0,6)+'/'+ar_file_struct[0].maskfile+'.gz',testind,testdat
mindex2map,testind,testdat,testmap

;Initilalise the SSZ data structure
blankmeta=ar_struct_init(struct='ar_ssz_smart2')
sszstruct=replicate(blankmeta,n_elements(strar))

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
spawn,'echo "#MAGTHRESH [G]; '+strtrim(params.magthresh,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#SMOOTHTHRESH [G]; '+strtrim(params.smooththresh,2)+'" >> '+fcsvzoo,/sh
spawn,'echo "#" >> '+fcsvzoo,/sh
spawn,'echo "#Units:" >> '+fcsvzoo,/sh
spawn,'echo "#..." >> '+fcsvzoo,/sh
spawn,'echo "#FORMAT; '+struct2format(blankmeta)+'" >> '+fcsvzoo,/sh
spawn,'echo "#'+strjoin(strupcase(strtrim(tag_names(blankmeta),2)),'; ')+'; " >> '+fcsvzoo,/sh


;Initialise counter for number of AR skips
narskips=0l

;Initialise number of data skips
nnenskips=0l

;Initialise SunspotZoo numbering
if not keyword_set(nzooinit) then nzoo=1l else nzoo=nzooinit

if n_elements(iniinit) eq 0 then iinit=0l else iinit=long(iniinit)

for i=iinit,n_elements(strdetect)-1l do begin
;Initialised value
sszstatus=0
	
	thismag=strdetect[i]

;if thismag.datafile eq 'fd_M_96m_01d.3651.0014.fits' then stop

if thismag.ncore eq 0 then continue
	
	
print,'This file date: '+file2time(thismag.maskfile)
	
	thisfmask=dpathmask+'/'+strmid(time2file(file2time(thismag.maskfile)),0,6)+'/'+thismag.maskfile+'.gz'
	
	if not file_exist(thisfmask) then begin
print,'WTF?! not finding the locally saved mask file! Skipping.'
		nnenskips=nnenskips+1l

;not finding the locally saved mask file! Skipping.
sszstatus=5
sszstruct[wdatafile].sszstatus=sszstatus

		continue
	endif

	
	mreadfits,thisfmask,maskind,mask
	mm=ar_core2mask(mask,smart=smmask)
	mask=fix(round(mm))
	mindex2map,maskind,mask,mapmask
	
;	wthismag=where(strdetect....)

	wdatafile=where(strar.datafile eq thismag.datafile)
	
	if wdatafile[0] eq -1 then begin
print,'WTF?! not finding the DATAFILE used to make the detections?!?! Skipping.'
		nnenskips=nnenskips+1l
		continue
	endif

;Data file was found
sszstatus=1
	
	arstr=strar[wdatafile]
;	propstr=strprop[wdatafile]
	detstr=ar_file_struct[wdatafile]
	
	nthisar=n_elements(arstr)

	if n_elements(detstr) ne nthisar then begin
print,'WTF?! not finding same number of ARs again?!?! Skipping.'
		nnenskips=nnenskips+1l

;The number of detected ARs in the file did not match between mask/meta data
sszstatus=2
sszstruct[wdatafile].sszstatus=sszstatus

		continue
	endif
	
;plot_map,mapmask

	thismagf=dpathfits+'/m'+strmid(time2file(file2time(thismag.maskfile)),0,6)+'/fdmg'+strmid(time2file(thismag.date),0,13)+'.fts'
	if not file_exist(thismagf) then begin
print,'Specified MDI FITS file does not exist!!!'
print,'checking for nearest match!!!'
		fmdichk=file_search(dpathfits+'/m'+strmid(time2file(thismag.date),0,6)+'/fdmg*')
		tmdichk=anytim(file2time(fmdichk))
		wbest=where(abs(tmdichk-anytim(thismag.date)) eq min(abs(tmdichk-anytim(thismag.date))))

		thismagf=fmdichk[wbest]

;		nnenskips=nnenskips+1l
		
;The MDI fits file has gone missing
;sszstatus=3
;sszstruct[wdatafile].sszstatus=sszstatus
		
;		continue

	endif

;Read in magnetogram
	thisdatmap=ar_readmag(thismagf,/mread)
	thismagorig=thisdatmap
	thisdatmap=ar_processmag(thisdatmap,limbmask=limbmask,cosmap=cosmap, rrdeg=rrdeg, params=params,/nocosmic,/nofilt)


;Make a YYYYMM directory to output stuff------------------>
	smart_cutouts_smart2_mkdirym, pathproj, strmid(time2file(file2time(thismag.maskfile)),0,6), thispathproj
	smart_cutouts_smart2_mkdirym, dpathpngs, strmid(time2file(file2time(thismag.maskfile)),0,6), thispathpngs
;	smart_cutouts_smart2_mkdirym, pathprojfits, strmid(time2file(file2time(thismag.maskfile)),0,6), thispathprojfits
;	smart_cutouts_smart2_mkdirym, pathcutoutfits, strmid(time2file(file2time(thismag.maskfile)),0,6), thispathcutoutfits
	smart_cutouts_smart2_mkdirym, pathfulldiskimg, strmid(time2file(file2time(thismag.maskfile)),0,6), thispathfulldiskimg


	arsszmeta=replicate(blankmeta,nthisar)

	for j=0l,nthisar-1l do begin
		
		sszn=string(nzoo,form='(I07)')
		
		thisid=arstr[j].arid

print,'ARID',arstr[j].arid

		thismask=mask
		thismask[where(mask ne thisid)]=0

		wmask=where(thismask eq thisid)
		
		if wmask[0] eq -1 then begin
print,'This ARID not found in the mask!!! Skipping.'
			narskips=narskips+1l

;Current ARID not found in the mask
sszstatus=4
sszstruct[wdatafile[j]].sszstatus=sszstatus

			continue
		endif
		
		thismask[wmask]=1

plot_mag,thisdatmap.data
contour,thismask,/over,level=0.5

		thismaxlimbdeg=limbmask*thismask*rrdeg
		if (where(finite(thismaxlimbdeg) ne 1))[0] ne -1 then thismaxlimbdeg[where(finite(thismaxlimbdeg) ne 1)]=0
		maxdeg=max(thismaxlimbdeg)
		
print,'MAXDEG = ',maxdeg/!dtor
		
		if maxdeg/!dtor gt 75. then begin
print,'AR is touching the limb!!! Skipping.'
			narskips=narskips+1l
			
;AR is touching the limb
sszstatus=6
sszstruct[wdatafile[j]].sszstatus=sszstatus
;stop

			continue
		endif



;DETERMINE MAGNETIC PROPERTIES---------------------------->
		thisposstr=ar_posprop(map=thisdatmap, mask=thismask, cosmap=cosmap, params=params, status=statuspos)
		thismagstr=ar_magprop(map=thisdatmap, mask=thismask, cosmap=cosmap, params=params, status=statusmag)
		thispslstr=ar_pslprop(thisdatmap, thismask, param=params, $
					/doproj, /dobppxscl, outproj=thisprojmag, outbpscl=projpxscl_bpsep, outmaskproj=projmask, $
					outpslmask=pslmaskt, outgradpsl=gradpsl, projmaxscale=1024)

;Test whether PSL module made images
if n_elements(thisprojmag) eq 1 and thisprojmag[0] eq -1 then begin
print,'NO AR was present in input data to PSL module!!! Skipping.'
			narskips=narskips+1l

;Current ARID not found in the mask
sszstatus=7
sszstruct[wdatafile[j]].sszstatus=sszstatus

			continue
		endif





;MAKE STANDARD HPC CUT-OUT SIZE--------------------------->

;Use the AR flux centroid in pixels and make a bounding box using specified width
		bboxxran=thisposstr.XCENFLX+[-xbuff/2.,xbuff/2.]
		bboxyran=thisposstr.YCENFLX+[-ybuff/2.,ybuff/2.]

;Crop to AR specified box size using the mask map
		thismaskmap=mapmask
		thismaskmap.data=thismask
		
		sub_map,thismaskmap,thisarmaskmap,xrange=bboxxran-[0.,1.],yrange=bboxyran-[0.,1.],/pixel,/noplot ;,dimensions=[xbuff,ybuff]
		sub_map,thisdatmap,thisardatmap,ref_map=thisarmaskmap,/preserve,/noplot

;Buffer out the map to the specified dimensions if smaller
		thisarmaskmap=map_buffer_2d(thisarmaskmap,xs=xbuff,ys=ybuff)
		thisardatmap=map_buffer_2d(thisardatmap,xs=xbuff,ys=ybuff)

;Get coordinates for plotting limb
		map2wcs,thisardatmap,wcsarmask
		add_prop,thisardatmap,wcs=wcsarmask,/repl
		thisardatcoord=wcs_get_coord(thisardatmap.wcs)
		thisardatrr=sqrt(thisardatcoord[0,*,*]^2.+thisardatcoord[1,*,*]^2.)
		offlimb=fltarr(xbuff,ybuff)
		offlimb[where(thisardatrr le thisardatmap.rsun)]=1.

;Make the cut-out plots:

		ardisplay=thisardatmap.data
		imgsz=size(ardisplay,/dim)
		
		wblanked=where(thisarmaskmap.data eq 0)
		if wblanked[0] ne -1 then begin
			drand=randomn(seed,n_elements(wblanked))
		
			if thisardatmap.index.interval eq 300 then drand=drand/max(drand)*params.magthresh/4. $
				else drand=drand/max(drand)*params.magthresh/2.
			ardisplay[wblanked]=drand
		endif
		
		wnan=where(offlimb eq 0)
		if wnan[0] ne -1 then ardisplay[wnan]=params.nan
		
		dispmap=thisardatmap
		add_prop,dispmap,data=ardisplay,/repl
		
		thisimg=thispathpngs+'ar_cutout_scl_'+string(nzoo,form='(I07)')
		
		setplotenv,file=thisimg+'.eps',/ps,xs=5,ys=5*imgsz[1]/float(imgsz[0])
			plot_image,magscl(ardisplay,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
;			if (where(finite(arrrdeg) ne 1))[0] ne -1 then arrrdeg[where(finite(arrrdeg) ne 1)]=90
;			contour,arrrdeg,level=1.5,color=255,/over,thick=20
			plot_map,thisardatmap,xticklen=0.0001,yticklen=0.0001,color=0,position=[0,0,1,1],/nodata,/noerase,thick=30
			draw_circle,0,0,thisardatmap.rsun,/data,color=255,thick=20
		closeplotenv


;MAKE MINIMUM SQUARE HPC CUT-OUT SIZE--------------------------->

;Use the AR flux centroid in pixels and make a bounding box using specified width
;		bboxxran=thisposstr.XCENbnd+[-ceil(arstr[j].arpxwidthx/2.),ceil(arstr[j].arpxwidthx/2.)]
;		bboxyran=thisposstr.YCENbnd+[-ceil(arstr[j].arpxwidthy/2.),ceil(arstr[j].arpxwidthy/2.)]

		bboxxran=[min(where(total(thismaskmap.data,2) gt 0)),max(where(total(thismaskmap.data,2) gt 0))]
		bboxyran=[min(where(total(thismaskmap.data,1) gt 0)),max(where(total(thismaskmap.data,1) gt 0))]

;Crop to AR specified box size using the mask map
;		sub_map,thismaskmap,thisarmaskmap,xrange=bboxxran-[0.,1.],yrange=bboxyran-[0.,1.],/pixel,/noplot
		sub_map,thismaskmap,thisarmaskmap,xrange=bboxxran,yrange=bboxyran,/pixel,/noplot
		sub_map,thisdatmap,thisardatmap,ref_map=thisarmaskmap,/preserve,/noplot

;Buffer out the map to the specified dimensions if smaller
		msksz=size(thisarmaskmap.data,/dim)
;		sqdim=max([arstr[j].arpxwidthx>msksz[0],arstr[j].arpxwidthy>msksz[1]])
		sqdim=max(msksz)
		thisarmaskmap=map_buffer_2d(thisarmaskmap,xs=sqdim,ys=sqdim)
		thisardatmap=map_buffer_2d(thisardatmap,xs=sqdim,ys=sqdim)

;Get coordinates for plotting limb
		map2wcs,thisardatmap,wcsarmask
		add_prop,thisardatmap,wcs=wcsarmask,/repl
		thisardatcoord=wcs_get_coord(thisardatmap.wcs)
		thisardatrr=sqrt(thisardatcoord[0,*,*]^2.+thisardatcoord[1,*,*]^2.)
		offlimb=fltarr(sqdim,sqdim)
		offlimb[where(thisardatrr le thisardatmap.rsun)]=1.

;Make the cut-out plots:

		ardisplay=thisardatmap.data
		imgsz=size(ardisplay,/dim)
		
		wblanked=where(thisarmaskmap.data eq 0)
		if wblanked[0] ne -1 then begin
			drand=randomn(seed,n_elements(wblanked))
		
			if thisardatmap.index.interval eq 300 then drand=drand/max(drand)*params.magthresh/4. $
				else drand=drand/max(drand)*params.magthresh/2.
			ardisplay[wblanked]=drand
		endif
		
		wnan=where(offlimb eq 0)
		if wnan[0] ne -1 then ardisplay[wnan]=params.nan
		
		dispmap=thisardatmap
		add_prop,dispmap,data=ardisplay,/repl
		
		thisimg=thispathpngs+'ar_cutout_sq_'+string(nzoo,form='(I07)')
		
		setplotenv,file=thisimg+'.eps',/ps,xs=5,ys=5
			plot_image,magscl(ardisplay,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
			plot_map,thisardatmap,xticklen=0.0001,yticklen=0.0001,color=0,position=[0,0,1,1],/nodata,/noerase,thick=30
			draw_circle,0,0,thisardatmap.rsun,/data,color=255,thick=20
		closeplotenv



;MAKE MINIMUM SQUARE PROJECTION SIZE---------------------->

;Make the projected plots:

		projsz=size(thisprojmag,/dim)
		datdisplay=thisprojmag
		
		projsqdim=max(projsz)
		datdisplaybuff=buffer_2d(datdisplay,xs=projsqdim,ys=projsqdim)
		projmaskbuff=buffer_2d(projmask,xs=projsqdim,ys=projsqdim)
		projszbuff=size(datdisplaybuff,/dim)
		
		wblanked=where(projmaskbuff eq 0) ; or datdisplay eq buffval)
		if wblanked[0] ne -1 then begin
			drand=randomn(seed,n_elements(wblanked))
		
			if thisardatmap.index.interval eq 300 then drand=drand/max(drand)*params.magthresh/8. $
				else drand=drand/max(drand)*params.magthresh/4.
			datdisplaybuff[wblanked]=drand
		endif
		
		thisimg=thispathproj+'ar_cutout_sq_'+string(nzoo,form='(I06)')
		
		setplotenv,file=thisimg+'.eps',/ps,xs=5,ys=5 ;*projsz[1]/float(projsz[0])
			plot_image,magscl(datdisplaybuff,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
		closeplotenv



;!!!!!!TEMP!!!!
goto,skipstupidprojsclimg

;MAKE SCALED PROJECTION SIZE------------------------------>

;Determine how much to change the projection scaling to make it 'to-scale'
		physscl=[xbuff,ybuff]/projpxscl_bpsep ;ar_pxscale(thisdatmap,/mmppx)
		datdispsz=size(datdisplay,/dim)
		
;		datprojblank=fltarr(physscl[0],physscl[1])
;		extrax=floor(abs(((projsz[0]-physscl[0]) <0 )/2.))
;		extray=floor(abs(((projsz[1]-physscl[1]) <0 )/2.))
;		lessx=floor(abs(((projsz[0]-physscl[0]) >0 )/2.))
;		lessy=floor(abs(((projsz[1]-physscl[1]) >0 )/2.))
;		projfillnx=((projsz[0]-lessx-1)<(datdispsz[0]-1))-lessx+1
;		projfillny=((projsz[1]-lessy-1)<(datdispsz[1]-1))-lessy+1
;		datprojblank[extrax : (extrax+projfillnx-1.)<(physscl[0]-1) , $
;				extray : (extray+projfillny-1.)<(physscl[1]-1)] = $
;			datdisplay[lessx : (projsz[0]-lessx-1)<(datdispsz[0]-1) , $
;				lessy:(projsz[1]-lessy-1)<(datdispsz[1]-1)]
;		datdisplay=datprojblank

		datdisplay=buffer_2d(datdisplay,val=0,xs=physscl[0],ys=physscl[1])

;Make sure the AR wasnt too big and was spilling over the edges
;If so, then buffer out one dimension of the image to maintain the correct ratio... 
		
		newsz=size(datdisplay,/dim)
		
;		intentratio=(newsz[0]/newsz[1])*(float(ybuff)/float(xbuff))
;		if intentratio lt 1 then intentsz=[newsz[0]/intentratio, newsz[1]]
;		if intentratio gt 1 then intentsz=[newsz[0],newsz[1]*intentratio]
;
;		datdisplay=buffer_2d(datdisplay,val=0,xs=intentsz[0],ys=intentsz[1])

		wblanked=where(datdisplay eq 0) ; or datdisplay eq buffval)
		if wblanked[0] ne -1 then begin
			drand=randomn(seed,n_elements(wblanked))
		
			if thisardatmap.index.interval eq 300 then drand=drand/max(drand)*params.magthresh/8. $
				else drand=drand/max(drand)*params.magthresh/4.
			datdisplay[wblanked]=drand
		endif
		
		thisimg=thispathproj+'ar_cutout_scl_'+string(nzoo,form='(I06)')
		
		dispprojsclsz=size(datdisplay)
		setplotenv,file=thisimg+'.eps',/ps,xs=5,ys=5*newsz[1]/float(newsz[0])
			plot_image,magscl(datdisplay,min=-magdisplay,max=magdisplay,/nobg),xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
		closeplotenv


;!!!!!!TEMP!!!!
skipstupidprojsclimg:




;MAKE FULL-DISK CONTEXT IMAGE----------------------------->
		
		thisimg=thispathfulldiskimg+'ar_fulldisk_'+string(nzoo,form='(I06)')
		
		dispfull=thismagorig.data
		woffdisp=where(limbmask ne 1)
		if woffdisp[0] ne -1 then dispfull[woffdisp]=params.nan
		
		setplotenv,file=thisimg+'.eps',/ps,xs=10,ys=10
			plot_mag,dispfull,min=-magdisplay,max=magdisplay,/nobg,xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=15
			contour,thismask*limbmask,level=0.5,/over,color=255,thick=10
			contour,limbmask,level=0.5,/over,color=255,thick=15
		closeplotenv







;MAKE FULL DISK PLOT





;WRITE CUTOUT/PROJECTION FITS FILES



;WRITE CSV FILES FOR POS, MAG, DETECT, SSZ...








;Save Fits of detection data/mask
;		map2index,thisardatmap,indardat

;		mwritefits, indardat, thisardatmap.data, outfile=thispathcutoutfits+'ar_cutoutmdi_'+time2file(file2time(thismag.maskfile))+'.arid'+string(thisid,form='(I03)')+'.fits'
;		spawn,'gzip -f '+thispathcutoutfits+'ar_cutoutmdi_'+time2file(file2time(thismag.maskfile))+'.arid'+string(thisid,form='(I03)')+'.fits',/sh

;		mwritefits, indardat, thisarmaskmap.data, outfile=thispathcutoutfits+'ar_cutoutmask_'+time2file(file2time(thismag.maskfile))+'.arid'+string(thisid,form='(I03)')+'.fits'
;		spawn,'gzip -f '+thispathcutoutfits+'ar_cutoutmask_'+time2file(file2time(thismag.maskfile))+'.arid'+string(thisid,form='(I03)')+'.fits',/sh


;Update the WCS
;		map2wcs,thisarmaskmap,wcsarmask
;		add_prop,thisarmaskmap,wcs=wcsarmask,/repl
;		map2wcs,thisardatmap,wcsdatmask
;		add_prop,thisardatmap,wcs=wcsdatmask,/repl




;Rotate deprojected image using the +- flux centroids to match the original image?

;Determine the flare truth?

;Determine the best matched NOAA num?


;thisposstr

;   ARID            INT              1
;   XCENBND         DOUBLE           105.50000
;   YCENBND         DOUBLE           348.00000
;   XCENFLX         DOUBLE           89.543692
;   YCENFLX         DOUBLE           337.96095
;   XCENAREA        DOUBLE           104.82748
;   YCENAREA        DOUBLE           345.73291
;   HCXBND          DOUBLE          -806.75780
;   HCYBND          DOUBLE          -325.53063
;   HCXFLX          DOUBLE          -838.41693
;   HCYFLX          DOUBLE          -345.44924
;   HCXAREA         DOUBLE          -808.09215
;   HCYAREA         DOUBLE          -330.02879
;   HGLONBND        DOUBLE          -64.154857
;   HGLATBND        DOUBLE          -20.976275
;   HGLONFLX        DOUBLE          -70.437181
;   HGLATFLX        DOUBLE          -21.993974
;   HGLONAREA       DOUBLE          -64.572682
;   HGLATAREA       DOUBLE          -21.245773
;   CARLONBND       DOUBLE           40.020033
;   CARLONFLX       DOUBLE           33.737709
;   CARLONAREA      DOUBLE           39.602208


;thismagstr

;   ARID            INT              1
;   AREABND         DOUBLE           30684.377
;   POSAREABND      DOUBLE           13869.893
;   NEGAREABND      DOUBLE           9627.7427
;   POSAREA         DOUBLE           6097.4344
;   NEGAREA         DOUBLE           2857.4544
;   TOTAREA         DOUBLE           8954.8888
;   BMAX            DOUBLE           2489.5206
;   BMIN            DOUBLE          -3514.0170
;   BMEAN           DOUBLE           37.554958
;   TOTFLX          DOUBLE       6.2321142e+22
;   IMBFLX          DOUBLE       1.4360272e+22
;   FRCFLX          DOUBLE          0.22201643
;   NEGFLX          DOUBLE       1.8572173e+22
;   POSFLX          DOUBLE       3.2408490e+22

;   ARID            INT              1
;   PSLLENGTH       FLOAT           172.320
;   PSLSGLENGTH     FLOAT           0.00000
;   PSLCURVATURE    DOUBLE           2.0619028
;   RVALUE          FLOAT           129130.
;   WLSG            FLOAT           227888.
;   BIPOLESEP_MM    FLOAT           11.0039
;   BIPOLESEP_PX    FLOAT           7.64035
;   BIPOLESEP_PROJ  FLOAT           45.5941


;thispslstr

;   ARID            INT              1
;   PSLLENGTH       FLOAT           172.320
;   PSLSGLENGTH     FLOAT           0.00000
;   PSLCURVATURE    DOUBLE           2.0619028
;   RVALUE          FLOAT           129130.
;   WLSG            FLOAT           227888.
;   BIPOLESEP_MM    FLOAT           11.0039
;   BIPOLESEP_PX    FLOAT           7.64035
;   BIPOLESEP_PROJ  FLOAT           45.5941


;arsszmeta

;   SSZN            STRING    ' '
;   DATAFILE        STRING    ' '
;   ARID            INT              0
;   DATE            STRING    ' '
;   HGPOS           STRING    ' '
;   HCPOS           STRING    ' '
;   PXPOS           STRING    ' '
;   PXSCL_HPC2STG   DOUBLE           0.0000000
;   DEG2DC          DOUBLE           0.0000000
;   NPSL            INT              0
;   BMAX            FLOAT           0.00000
;   AREA            FLOAT           0.00000
;   AREAFRAC        DOUBLE           0.0000000
;   AREATHRESH      FLOAT           0.00000
;   FLUX            FLOAT           0.00000
;   FLUXFRAC        DOUBLE           0.0000000
;   BIPOLESEP       DOUBLE           0.0000000
;   PSLLENGTH       DOUBLE           0.0000000
;   PSLCURVATURE    DOUBLE           0.0000000
;   RVALUE          FLOAT           0.00000
;   WLSG            FLOAT           0.00000
;   POSSTATUS       INT              0                         
;   MAGSTATUS       INT              0                         
;   DETSTATUS       INT              0                         
;   SSZSTATUS       INT              0




;make and fill structure for SSZ meta file CSV-------------------------------->
;sszn,datafile,arid,date,
;hgpos,hcpos,pxpos,deg2dc,
;npsl,bmax,area,areafrac,areathresh,flux,fluxfrac,bipolesep,
;psllength,pslcurvature,rvalue,wlsg,
;posstatus,magstatus,detstatus,sszstatus

print,'NZOO=',nzoo

		arsszmeta[j].sszn=string(nzoo,form='(I07)')
		arsszmeta[j].datafile=thismag.datafile
		arsszmeta[j].arid=arstr[j].arid
		arsszmeta[j].date=anytim(thismag.date,/vms)

		arsszmeta[j].hgpos=strjoin(strtrim([string(thisposstr.HGLONFLX,form='(F15.5)'),string(thisposstr.HGLATFLX,form='(F15.5)')],2),',')
		arsszmeta[j].hcpos=strjoin(strtrim([string(thisposstr.HCXFLX,form='(F15.5)'),string(thisposstr.HCYFLX,form='(F15.5)')],2),',')
		arsszmeta[j].pxpos=strjoin(strtrim([string(thisposstr.XCENFLX,form='(F15.5)'),string(thisposstr.YCENFLX,form='(F15.5)')],2),',')
		arsszmeta[j].deg2dc=gc_dist([0.,0.],[thisposstr.HGLONFLX,thisposstr.HGLATFLX])
		arsszmeta[j].npsl=arstr[j].NARPSL
		arsszmeta[j].bmax=abs(thismagstr.bmax) > abs(thismagstr.bmin)
		arsszmeta[j].area=thismagstr.AREABND
		arsszmeta[j].areafrac=(thismagstr.POSAREA-abs(thismagstr.negAREA))/thismagstr.TOTAREA
		arsszmeta[j].areathresh=thismagstr.TOTAREA
		arsszmeta[j].flux=thismagstr.TOTFLX
		arsszmeta[j].fluxfrac=thismagstr.FRCFLX
		
		arsszmeta[j].bipolesep=thispslstr.bipolesep_mm
		arsszmeta[j].psllength=thispslstr.PSLLENGTH
		arsszmeta[j].pslcurvature=thispslstr.pslcurvature
		arsszmeta[j].rvalue=thispslstr.RVALUE
		arsszmeta[j].wlsg=thispslstr.WLSG
		
		arsszmeta[j].posstatus=statuspos
		arsszmeta[j].magstatus=statusmag
		arsszmeta[j].detstatus=thismag.status
		arsszmeta[j].sszstatus=sszstatus

;Fill big structure array		
		sszstruct[wdatafile[j]]=arsszmeta[j]

;Write line into the Meta CSV file 
		write_data_file, arsszmeta[j], filecsv=fcsvzoo, /append





;DEBUGGING----------------->
;plot_image,magscl(datdisplay,min=-magdisplay,max=magdisplay,/nobg) ;,xticklen=0.0001,yticklen=0.0001,position=[0,0,1,1],color=0,thick=30
;plot_map,dispmap,/nodata,/noerase
;oplot,projlimbxy[0,*],projlimbxy[1,*],color=255,thick=20
;DEBUGGING----------------->

;stop

		nzoo=nzoo+1l
		
		print,'I = ',i
		print,'J = ',j
	endfor
	
endfor

print,'!!!! '
help,nnenskips
print,'!!!! '




stop

end
