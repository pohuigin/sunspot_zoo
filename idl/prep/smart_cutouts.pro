;Script to generate a 10 image test data set
;Makes SMART cut-outs for 10 regions using the standard method
;(higgins et al. 2011)
;	Set A - pixels outside contour are zeroed, scaling is +-700
;       Set B - Pixels outside set to gaussian noise, same scaling 
;	...

pro smart_cutouts,skip1=skip1,skip2=skip2,skip3=skip3,skip4=skip4,skip5=skip5

dpath='~/projects/zooniverse/science_gallery/'

fsmart=file_search(dpath+'images/smart*sav')

fpath='~/projects/zooniverse/science_gallery/images/'

imgpath='~/projects/zooniverse/data_set/smart_set/'

;magnetogram times
tmag=['14-may-2005 17:36:00','27-oct-2003 12:47:00','8-feb-2001 12:51:00']

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
