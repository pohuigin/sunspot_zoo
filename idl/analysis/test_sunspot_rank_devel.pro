pro test_sunspot_rank_devel

nvolun=6

imgind=findgen(15) ;[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

;Classifications

class=['g','b','a','b','g','g','g','g','g','b','b','b','g','g','b']
kdleclass=['b', 'b', 'a', 'b', 'g', 'g', 'b', 'g', 'g', 'g', 'b', 'b', 'b', 'g', 'd']
sopmclass=['g','b','a','b','g','g','g','g','g','b','b','b','g','g','b']
;(a=alpha, b=beta, g=gamma)

;Rankings:

;Paul:
paulsize=[0,4,5,7,6,12,8,1,13,14,9,10,2,11,3]
paulstrn=[8,7,4,9,12,5,1,0,10,14,11,13,3,6,2]
paulcplx=[7,4,8,5,0,12,9,6,13,14,1,10,3,11,2]
paulcpct=[11,3,8,7,4,10,14,13,12,1,5,0,2,6,2]


;David P-S:
dvdpsize=[4,0,5,7,12,1,8,13,2,14,9,10,3,11] ;6?
dvdpstrn=[4,7,8,5,0,12,9,1,10,13,14,11,3,2] ;6?
dvdpcplx=[7,4,8,9,5,0,12,13,1,14,10,2,11,3] ;6?
dvdpcpct=[8,7,4,9,12,5,0,10,13,1,11,3,14,2] ;6?

;Greg: 
;(by integrated area above threshold):
gregsize=[04, 07, 00, 05, 08, 12, 01, 06, 14, 13, 10, 09, 02, 03, 14]
;(by bounding box extent):
gregsize2=[04, 00, 05, 07, 12, 06, 08, 01, 13, 14, 02, 09, 10, 11, 03]
;(by integrated area of core coherent structures):
gregsize3=[04, 07, 08, 05, 00, 12, 01, 09, 10, 14, 13, 11, 03, 06, 02]

gregstrn=[04, 07, 08, 05, 12, 09, 01, 00, 10, 13, 14, 11, 03, 06, 02]
gregcplx=[04, 07, 05, 08, 00, 12, 09, 06, 01, 14, 13, 10, 03, 11, 02]
gregcpct=[07, 04, 08, 09, 10, 05, 13, 10, 12, 00, 14, 11, 03, 06, 02]

;Caitlin:
caitsize=[4,0,7,5,8,6,1,12, 13, 14,9,10,2,3,11]
caitstrn=[4,7,8,5,9,1, 0,12,13, 14, 10,11,3,6,2]
caitcplx=[7,4,8,6,5,1,10, 14, 13, 9,0,12,3,11,2]
caitcpct=[8 ,9, 7, 4, 5,11,14,13,3,1,0,12,10,2,6] 

;David O'C
dvocsize=[4, 0, 5, 7, 12, 8, 6, 1, 13, 14, 2, 9, 10, 11, 3]
dvocstrn=[4, 7, 8, 5, 0, 12, 1, 9, 14, 13, 10, 11, 3, 6, 2]
dvoccplx=  [4, 0, 7, 5, 12, 8, 9, 1, 13, 14, 6, 10, 11, 3, 2]
;dvoccpct=

;Tony H.
tonhsize=[07,04,0,05,06,08,12,01,09,10,13,14,02,11,03]
tonhstrn=[07,04,08,0,05,12,09,01,10,06,14,13,11,03,02]
;Most complex to least: []
tonhcpct= [08,09,10,11,03,07,12,14,13,01,04,05,06,0,02]

;Sophie M.
sopmsize=[4,0,5,7,6,12,1,8,13,14,9,10,2,3,11]
sopmstrn=[4,7,8,9,5,0,12,1,14,10,13,11,3,6,2]
sopmcplx=[4,7,8,5,0,12,9,6,13,14,1,10,11,3,2]
sopmcpct=[11,3,8,7,4,10,9,13,14,12,1,6,5,0,2]

;KD L.
kdlesize=[4,5,0,7,12,1,6,8,14,15,9,2,10,11,3]  
kdlestrn=[4,7,8,9,12,5,1,0,13,14,10,11,3,6,2]
kdlecplx=[7,4,8,9,13,5,0,11,12,1,14,10,3,6,2]
kdlecpct= [7,4,8,13,9,5,10,3,11,14,12,1,0,6,2]

;Michael Zooniverse
miczsize=[4, 7, 0, 5, 8, 12, 1, 6, 9, 10, 13, 14, 2, 11, 3]
miczstrn=[4, 7, 0, 5, 8, 12, 9, 1, 10, 13, 14, 3, 11, 6, 2]
miczcplx=[4, 7, 5, 0, 12, 8, 1, 9, 6, 10, 14, 13, 3, 11, 2]
miczcpct=[7, 8, 9, 12, 4, 1, 14, 11, 3, 10, 13, 5, 0, 6, 2]


rankimgsize=fltarr(15,15)

rankimgsize=sunspot_add_ranking(rankimgsize, paulsize)
rankimgsize[imgind[1:*],sort(dvdpsize)]=rankimgsize[imgind[1:*],sort(dvdpsize)]+1
rankimgsize=sunspot_add_ranking(rankimgsize, gregsize2)
rankimgsize=sunspot_add_ranking(rankimgsize, caitsize)
rankimgsize=sunspot_add_ranking(rankimgsize, dvocsize)
rankimgsize=sunspot_add_ranking(rankimgsize, tonhsize)
rankimgsize=sunspot_add_ranking(rankimgsize, sopmsize)
rankimgsize=sunspot_add_ranking(rankimgsize, kdlesize)
rankimgsize=sunspot_add_ranking(rankimgsize, miczsize)

rankimgsizes=sunspot_order_density(rankimgsize, sortrank=savgsize)

!p.background=255
!p.color=0
!x.margin=[10,15]

plot_image,-rankimgsizes,xtickmajor=13,ytickmajor=13,ytit='SIZE RANKING',xtit='IMAGE INDEX',chars=2,xtickname=strarr(10)+' ',xticklen=0.0001
vline,imgind-0.5,color=255,lines=1
hline,imgind-0.5,color=255,lines=1
xyouts,imgind-0.25,fltarr(15)-1,string(savgsize,form='(I02)'),chars=2,/data

plot_image,-transpose(rebin(findgen(max(rankimgsizes)+1,1),max(rankimgsizes)+1,2)),position=[0.90,0.13,0.935,0.95],xtickname=strarr(10)+' ',/nosq,xticklen=0.0001, yticklen=0.0001,chars=2,/noerase,ytit='# of Votes' 

window_capture,file='test_devel_size'

stop



rankimgstrn=fltarr(15,15)
rankimgstrn[imgind,sort(paulstrn)]=rankimgstrn[imgind,sort(paulstrn)]+1
rankimgstrn[imgind[1:*],sort(dvdpstrn)]=rankimgstrn[imgind[1:*],sort(dvdpstrn)]+1
rankimgstrn[imgind,sort(gregstrn)]=rankimgstrn[imgind,sort(gregstrn)]+1
rankimgstrn[imgind,sort(caitstrn)]=rankimgstrn[imgind,sort(caitstrn)]+1
rankimgstrn[imgind,sort(dvocstrn)]=rankimgstrn[imgind,sort(dvocstrn)]+1
rankimgstrn[imgind,sort(tonhstrn)]=rankimgstrn[imgind,sort(tonhstrn)]+1
rankimgstrn[imgind,sort(sopmstrn)]=rankimgstrn[imgind,sort(sopmstrn)]+1
rankimgstrn[imgind,sort(kdlestrn)]=rankimgstrn[imgind,sort(kdlestrn)]+1
rankimgstrn[imgind,sort(miczstrn)]=rankimgstrn[imgind,sort(miczstrn)]+1

rankimgstrns=sunspot_order_density(rankimgstrn, sortrank=savgstrn)

plot_image,-rankimgstrns,xtickmajor=13,ytickmajor=13,ytit='STRENGTH RANKING',xtit='IMAGE INDEX',chars=2,xtickname=strarr(10)+' ',xticklen=0.0001
vline,imgind-0.5,color=255,lines=1
hline,imgind-0.5,color=255,lines=1
xyouts,imgind-0.25,fltarr(15)-1,string(savgstrn,form='(I02)'),chars=2,/data

plot_image,-transpose(rebin(findgen(max(rankimgstrns)+1,1),max(rankimgstrns)+1,2)),position=[0.90,0.13,0.935,0.95],xtickname=strarr(10)+' ',/nosq,xticklen=0.0001, yticklen=0.0001,chars=2,/noerase,ytit='# of Votes'


window_capture,file='test_devel_strn'

stop



rankimgcpct=fltarr(15,15)
rankimgcpct[imgind,sort(paulcpct)]=rankimgcpct[imgind,sort(paulcpct)]+1
rankimgcpct[imgind[1:*],sort(dvdpcpct)]=rankimgcpct[imgind[1:*],sort(dvdpcpct)]+1
rankimgcpct[imgind,sort(gregcpct)]=rankimgcpct[imgind,sort(gregcpct)]+1
rankimgcpct[imgind,sort(caitcpct)]=rankimgcpct[imgind,sort(caitcpct)]+1
rankimgcpct[imgind,sort(tonhcpct)]=rankimgcpct[imgind,sort(tonhcpct)]+1
rankimgcpct[imgind,sort(sopmcpct)]=rankimgcpct[imgind,sort(sopmcpct)]+1
rankimgcpct[imgind,sort(kdlecpct)]=rankimgcpct[imgind,sort(kdlecpct)]+1
rankimgcpct[imgind,sort(miczcpct)]=rankimgcpct[imgind,sort(miczcpct)]+1

rankimgcpcts=sunspot_order_density(rankimgcpct, sortrank=savgcpct)

plot_image,-rankimgcpcts,xtickmajor=13,ytickmajor=13,ytit='COMPACTNESS RANKING',xtit='IMAGE INDEX',chars=2,xtickname=strarr(10)+' ',xticklen=0.0001
vline,imgind-0.5,color=255,lines=1
hline,imgind-0.5,color=255,lines=1
xyouts,imgind-0.25,fltarr(15)-1,string(savgcpct,form='(I02)'),chars=2,/data

plot_image,-transpose(rebin(findgen(max(rankimgcpcts)+1,1),max(rankimgcpcts)+1,2)),position=[0.90,0.13,0.935,0.95],xtickname=strarr(10)+' ',/nosq,xticklen=0.0001, yticklen=0.0001,chars=2,/noerase,ytit='# of Votes' 


window_capture,file='test_devel_cpct'

stop



rankimgcplx=fltarr(15,15)
rankimgcplx[imgind,sort(paulcplx)]=rankimgcplx[imgind,sort(paulcplx)]+1
rankimgcplx[imgind[1:*],sort(dvdpcplx)]=rankimgcplx[imgind[1:*],sort(dvdpcplx)]+1
rankimgcplx[imgind,sort(gregcplx)]=rankimgcplx[imgind,sort(gregcplx)]+1
rankimgcplx[imgind,sort(caitcplx)]=rankimgcplx[imgind,sort(caitcplx)]+1
rankimgcplx[imgind,sort(dvoccplx)]=rankimgcplx[imgind,sort(dvoccplx)]+1
rankimgcplx[imgind,sort(sopmcplx)]=rankimgcplx[imgind,sort(sopmcplx)]+1
rankimgcplx[imgind,sort(kdlecplx)]=rankimgcplx[imgind,sort(kdlecplx)]+1
rankimgcplx[imgind,sort(miczcplx)]=rankimgcplx[imgind,sort(miczcplx)]+1

rankimgcplxs=sunspot_order_density(rankimgcplx, sortrank=savgcplx)

plot_image,-rankimgcplxs,xtickmajor=13,ytickmajor=13,ytit='COMPLEXITY RANKING',xtit='IMAGE INDEX',chars=2,xtickname=strarr(10)+' ',xticklen=0.0001
vline,imgind-0.5,color=255,lines=1
hline,imgind-0.5,color=255,lines=1
xyouts,imgind-0.25,fltarr(15)-1,string(savgcplx,form='(I02)'),chars=2,/data

plot_image,-transpose(rebin(findgen(max(rankimgcplxs)+1,1),max(rankimgcplxs)+1,2)),position=[0.90,0.13,0.935,0.95],xtickname=strarr(10)+' ',/nosq,xticklen=0.0001, yticklen=0.0001,chars=2,/noerase,ytit='# of Votes' 


window_capture,file='test_devel_cplx'

stop


rankimgrand=fltarr(15,15)
for i=0,nvolun-1 do begin
   rankimgrand[imgind,sort(randomu(seed,15))]=rankimgrand[imgind,sort(randomu(seed,15))]+1
endfor

rankimgrands=sunspot_order_density(rankimgrand, sortrank=savgrand)

plot_image,-rankimgrands,xtickmajor=13,ytickmajor=13,ytit='RANDOM RANKING',xtit='IMAGE INDEX',chars=2,xtickname=strarr(10)+' ',xticklen=0.0001
vline,imgind-0.5,color=255,lines=1
hline,imgind-0.5,color=255,lines=1
xyouts,imgind-0.25,fltarr(15)-1,string(savgrand,form='(I02)'),chars=2,/data

plot_image,-transpose(rebin(findgen(max(rankimgrands)+1,1),max(rankimgrands)+1,2)),position=[0.90,0.13,0.935,0.95],xtickname=strarr(10)+' ',/nosq,xticklen=0.0001, yticklen=0.0001,chars=2,/noerase,ytit='# of Votes' 


window_capture,file='test_devel_rand'

stop






end
