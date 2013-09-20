function sunspot_add_ranking, inimage, ranking

image=inimage

dim=size(image,/dim)
imgind=findgen(dim[0])

image[imgind,sort(ranking)]=image[imgind,sort(ranking)]+1





return,image


end
