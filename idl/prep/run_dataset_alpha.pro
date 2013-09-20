pro run_dataset_alpha, docutouts=docutouts, dofulldisk=dofulldisk

fpathimg='~/science/projects/zooniverse/data_set/alpha/pngs_fulldisk/'

fpath='~/science/projects/zooniverse/data_set/alpha/'
fmeta=fpath+'smart_cutouts_metadata_alpha.txt'
fpathdata=fpath+'fits_jsoc/
savcutoutpath=fpath+'sav_cutout/'

fparam='~/science/projects/zooniverse/data_set/ar_param_zooniverse.txt'

;Make the cut-outs
if keyword_set(docutouts) then $
   smart_cutouts_alpha,/skip1, outmetafile=metafile


;Make the full-disk context images
if keyword_set(dofulldisk) then $
   smart_fulldisk_alpha, metafile=fmeta, fparam=fparam, pathimg=fpathimg, pathdata=fpathdata, savcutoutpath=savcutoutpath


stop

end
