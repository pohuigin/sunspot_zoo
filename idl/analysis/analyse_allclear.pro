pro analyse_allclear

str=read_data_file('results/gamma/2014-03-29_sunspot_rankings.csv')

plot,str.flux,str.score,ps=4,xran=[1d18,4d23],yran=[900,1500],xtit='Total Mag. Flux',ytit='Complex. Score',chars=2
setcolors,/sys
wfl=where(str.c1flr24hr eq 'true')
oplot,str[wfl].flux,str[wfl].score,ps=4,color=!red           
wfl2=where(str.m1flr12hr eq 'true')               
oplot,str[wfl2].flux,str[wfl2].score,ps=4,color=!blue

stop

plot,str.flux,str.score,ps=4,xran=[1d21,4d23],yran=[900,1500],/xlog,xtit='Total Mag. Flux',ytit='Complex. Score',chars=2
setcolors,/sys
wfl=where(str.c1flr24hr eq 'true')
oplot,str[wfl].flux,str[wfl].score,ps=4,color=!red           
wfl2=where(str.m1flr12hr eq 'true')               
oplot,str[wfl2].flux,str[wfl2].score,ps=4,color=!blue

stop

help,where(str.hale eq 'alpha')
help,where(str.hale eq 'beta')
help,where(strpos(str.hale,'gamma') ne -1 or strpos(str.hale,'delta') ne -1)

setcolors,/sys
plot_hist,str[where(strpos(str.hale,'gamma') ne -1 or strpos(str.hale,'delta') ne -1)].area,bin=1000,yran=[0,300]
plot_hist,str[where(str.hale eq 'alpha')].area,bin=1000,/oplot,color=!red
plot_hist,str[where(str.hale eq 'beta')].area,/oplot,bin=1000,color=!blue

stop

setplotenv,/ps,file='results/gamma/plots/haledist_vs_score.eps'
setcolors,/sys,/sil
plot_hist,str[where(strpos(str.hale,'gamma') ne -1 or strpos(str.hale,'delta') ne -1)].score,bin=10,ytit='# of Detections',xtit='Elo Score',chars=3,yran=[0,300]
plot_hist,str[where(str.hale eq 'beta')].score,/oplot,bin=10,color=!blue
plot_hist,str[where(str.hale eq 'alpha')].score,bin=10,/oplot,color=!red
vline,median(str[where(strpos(str.hale,'gamma') ne -1 or strpos(str.hale,'delta') ne -1)].score),yran=[200,300]
vline,median(str[where(str.hale eq 'beta')].score),yran=[200,300],color=!blue
vline,median(str[where(str.hale eq 'alpha')].score),yran=[200,300],color=!red
closeplotenv

gmed=median(str[where(strpos(str.hale,'gamma') ne -1 or strpos(str.hale,'delta') ne -1)].score)
bmed=median(str[where(str.hale eq 'beta')].score)
amed=median(str[where(str.hale eq 'alpha')].score)

sscore=sort(str.score)
strsort=str[sscore]
wlta=where(strsort.score le amed)
wgtaltb=where(strsort.score gt amed and strsort.score le bmed)
wgtbltg=where(strsort.score gt bmed and strsort.score le gmed)
wgtg=where(strsort.score gt gmed)

;set amed =25/2., bmed=25+25/2., gmed=75

slta=strsort[wlta].score
slta=slta-min(slta)
slta=slta/max(slta)*(25./2.)

sgtaltb=strsort[wgtaltb].score
sgtaltb=sgtaltb-min(sgtaltb)
sgtaltb=sgtaltb/max(sgtaltb)*(25)+(25/2.)

sgtbltg=strsort[wgtbltg].score
sgtbltg=sgtbltg-min(sgtbltg)
sgtbltg=sgtbltg/max(sgtbltg)*(25+25/2.)+(25+25/2.)

sgtg=strsort[wgtg].score
sgtg=sgtg-min(sgtg)
sgtg=sgtg/max(sgtg)*(25.)+(75.)

strsort[wlta].score=slta
strsort[wgtaltb].score=sgtaltb
strsort[wgtbltg].score=sgtbltg
strsort[wgtg].score=sgtg

wm1flr=where(strsort.M1FLR12HR eq 'true')
yscorem1=histogram(strsort[wm1flr].score,bin=5,loc=xscorem1)
yscoreall=histogram(strsort.score,bin=5,loc=xscoreall)
stop

setplotenv,/ps,file='results/gamma/plots/haledist_vs_score_scaled.eps'
setcolors,/sys,/sil
plot_hist,strsort[where(strpos(strsort.hale,'gamma') ne -1 or strpos(strsort.hale,'delta') ne -1)].score,bin=1,ytit='# of Detections',xtit='Complexity Scale',chars=3,yran=[0,300],xmarg=[10,10]
plot_hist,strsort[where(strsort.hale eq 'beta')].score,/oplot,bin=1,color=!blue
plot_hist,strsort[where(strsort.hale eq 'alpha')].score,bin=1,/oplot,color=!red
oplot,xscorem1,yscorem1/float(yscoreall)*(300./0.2),ps=10,color=150
vline,median(strsort[where(strpos(strsort.hale,'gamma') ne -1 or strpos(strsort.hale,'delta') ne -1)].score),yran=[200,300]
vline,median(strsort[where(strsort.hale eq 'beta')].score),yran=[200,300],color=!blue
vline,median(strsort[where(strsort.hale eq 'alpha')].score),yran=[200,300],color=!red
axis,yaxis=1,yran=[0,0.2],ytit='M1 Flare Probability',color=150,chars=3
closeplotenv


plotsym,0,1,/fill
setplotenv,/ps,file='results/gamma/plots/cplxscale_vs_flux.eps'
setcolors,/sys,/sil
plot,strsort.flux,strsort.score,xtit='Flux [Mx]',ytit='Complexity Scale',ps=8,xran=[0,2d23],/xsty,chars=3
oplot,strsort[wm1flr].flux,strsort[wm1flr].score,ps=8,color=!red
closeplotenv

;normalise the distributions
;find where they overlap and draw lines between them
;then plot the new groups against area and see if there is a big dependence on area
;for alpha, beta, gamma groups, there is NOT a big dependence on area.

stop

end
