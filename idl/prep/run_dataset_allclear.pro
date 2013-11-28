pro run_dataset_allclear, docutouts=docutouts, dofulldisk=dofulldisk,debug=debug,iinit=iinit

fpathimg='~/science/projects/sunspot_zoo/data_set/all_clear/pngs_fulldisk/'

fpath='~/science/projects/sunspot_zoo/data_set/all_clear/'
;fmeta=fpath+'smart_cutouts_metadata_allclear_'+time2file(systim(/utc))+'.txt'
fmeta=fpath+'smart_cutouts_metadata_allclear.beta.1.20131127_0159.txt'
fpathdata=fpath+'nwra_fits/'
;savcutoutpath=fpath+'sav_cutout/'

fparam='~/science/projects/sunspot_zoo/data_set/ar_param_zooniverse.txt'

;Make the cut-outs
if keyword_set(docutouts) then $
   smart_cutouts_allclear, inmetafile=fmeta, fparam=fparam,debug=debug,iinit=iinit


;Make the full-disk context images
if keyword_set(dofulldisk) then $
   smart_fulldisk_allclear, metafile=fmeta, fparam=fparam, pathimg=fpathimg, pathdata=fpathdata;, $
;      savcutoutpath=savcutoutpath, params=inparams


stop

end
