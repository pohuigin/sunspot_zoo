;reorder the density plot by average ranking
;	1. determine center of light for each column
;		-gives average ranking for given SSG
;	2. order in X-direction by average rank

function sunspot_order_density, inimage, sortrank=srank

image = inimage

sz=(size(image,/dim))

ny=sz[0]

nx=sz[1]

imgind=findgen(ny)

avgarr=fltarr(nx)
for i=0,nx-1 do avgarr[i]=total(image[i,*]*imgind)/total(imgind)

srank=sort(avgarr)



image=image[srank,*]









return,image

end
