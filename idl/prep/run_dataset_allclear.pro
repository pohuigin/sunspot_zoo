pro run_dataset_allclear, docutouts=docutouts, dofulldisk=dofulldisk

fpathimg='~/science/projects/sunspot_zoo/data_set/all_clear/pngs_fulldisk/'

fpath='~/science/projects/sunspot_zoo/data_set/all_clear/'
fmeta=fpath+'smart_cutouts_metadata_allclear.txt'
fpathdata=fpath+'nwra_fits/'
;savcutoutpath=fpath+'sav_cutout/'

fparam='~/science/projects/sunspot_zoo/data_set/ar_param_zooniverse.txt'

;Make the cut-outs
if keyword_set(docutouts) then $
   smart_cutouts_allclear, inmetafile=fmeta, fparam=fparam


;Make the full-disk context images
if keyword_set(dofulldisk) then $
   smart_fulldisk_allclear, metafile=fmeta, fparam=fparam, pathimg=fpathimg, pathdata=fpathdata, $
      savcutoutpath=savcutoutpath, params=inparams


stop

end
