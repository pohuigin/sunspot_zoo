;Make a list of the largest flare produced by each NOAA AR using the latest events list
;save the time, location, noaa num, class?

pro run_list_noaa_maxflare

restore,'~/science/projects/stereo_sympathetic_flaring/data/last_events_extract_noaa.sav',/ver
restore,'~/science/projects/stereo_sympathetic_flaring/data/get_lastevents_list.sav',/ver
restore,'~/science/data/srs_archive/srs_str_1997_2013.sav',/ver

plotpath='~/science/projects/sunspot_zoo/'
datapath='~/science/projects/sunspot_zoo/'

;Initialise CSV file
fcsv=datapath+'run_list_noaa_maxflare.txt'

format='A,A,A,LL,LL,A,A,A,A,A'
create_struct,strblank,'',['noaa','noaa_date','flr_date','noaa_tim','flr_tim','max_flr','hale_cls','mcint_cls','srs_hg_lonlat','flr_hg_lonlat'],format2create_struct(format)

;Initialise YAFTA meta CSV file
write_data_file, strblank, filecsv=fcsv, formstring=format, $
	header=['#Run date:'+systim(/utc),'#This meta file was created using run_list_noaa_maxflare.pro','#This meta file is meant to emulate Sammis/Tang/Zirin 2000.','#It should allow one recreate Figure 2 in the paper.','#The LastEvents list and GET_NAR was used for the NOAA and flare info.'], /nodata

!p.color=0
!p.background=255


;Longify noaa numbers to fix string matching problem
noaanums=long(noaanums)
srsnoaanums=long(SRS_STR_1997_2013.name)


;Sort Flares by noaa number

nflare=n_elements(lescat)
tim=anytim(lescat.date_obs)

;make sure list is sorted in time
snoaa=sort(noaanums)
tim=tim[snoaa]
noaanums=noaanums[snoaa]
lescat=lescat[snoaa]

smart_nsew2hg, lescat.HELIO, flrlat, flrlon


;Sort SRS by NOAA number

nsrs=n_elements(SRS_STR_1997_2013)
ssrs=sort(srsnoaanums)
SRS_STR_1997_2013=SRS_STR_1997_2013[ssrs]
srsnoaanums=srsnoaanums[ssrs]

smart_nsew2hg, SRS_STR_1997_2013.loc, srslat, srslon 


;Match flares to NOAA regions

flrnoaau=noaanums[uniq(noaanums)]

srsnoaau=(srsnoaanums)[uniq(srsnoaanums)]

match,flrnoaau,srsnoaau,mflrsrs,msrsflr

noaamatched=flrnoaau[mflrsrs]
nunoaa=n_elements(noaamatched)


for i=0,nunoaa-1 do begin

	thisnoaa=noaamatched[i]


;Get SRS info for this NOAA
	wsrs=where(srsnoaanums eq thisnoaa)
	
	thissrs=SRS_STR_1997_2013[wsrs]
	thissrslat=srslat[wsrs]
	thissrslon=srslon[wsrs]
	
	thissrstim=anytim(thissrs.APP_DATE)
	
	
;Get FLR info for this NOAA	
	wflr=where(noaanums eq thisnoaa)

	thisflrs=lescat[wflr]
	thisflrslat=flrlat[wflr]
	thisflrslon=flrlon[wflr]
	
	thisflrcls=goes_class2int(thisflrs.class)
	
;If multiplemaximums found take the first one

	wmax=(where(thisflrcls eq max(thisflrcls)))[0]

	maxflrcls=thisflrs[wmax].class
	
	maxflrdate=thisflrs[wmax].FPEAK

	maxflrtim=anytim(maxflrdate)

	maxflrloc=strjoin(strtrim([thisflrslon[wmax],thisflrslat[wmax]],2),',')

	
;Find best match for SRS-Max Flare (take first match if multiple are found)

	wsrsmaxflr=(where(abs(thissrstim-maxflrtim) eq min(abs(thissrstim-maxflrtim))))[0]
	
	
;Get SRS info for time of max flare
	
	maxsrsdate=thissrs[wsrsmaxflr].app_date
	
	maxsrstim=anytim(maxsrsdate)
	
	maxsrsmtwil=thissrs[wsrsmaxflr].MTWIL
	
	maxsrsmcint=thissrs[wsrsmaxflr].MCINT

	maxsrsloc=strjoin(strtrim([thissrslon[wsrsmaxflr],thissrslat[wsrsmaxflr]],2),',')
	
;Input max flare info into structure

	thiscsvstruct=strblank

	thiscsvstruct.noaa=thisnoaa
	thiscsvstruct.noaa_date=maxsrsdate
	thiscsvstruct.flr_date=maxflrdate
	thiscsvstruct.noaa_tim=maxsrstim
	thiscsvstruct.flr_tim=maxflrtim
	thiscsvstruct.max_flr=maxflrcls
	thiscsvstruct.hale_cls=maxsrsmtwil
	thiscsvstruct.mcint_cls=maxsrsmcint
	thiscsvstruct.srs_hg_lonlat=maxsrsloc
	thiscsvstruct.flr_hg_lonlat=maxflrloc

;Write structure into CSV
	
	write_data_file, thiscsvstruct, filecsv=fcsv, formstring=format, /append

	

endfor


stop

end

