;Ended up using JSOC query instead
;JSOC query: mdi.fd_M_lev182[2001.01.01/1460d@27d]
;JSOC_20130629_558


pro get_data_alpha

;times=datearr(tstart, tend, vms=vms, seconds=seconds, minutes=minutes, hours=hours, days=days

trange=['1-jan-2001','1-jan-2005']

times=anytim(timegrid(trange[0], trange[1], days=27),/vms)

ntimes=n_elements(times)

for i=0,ntimes-1 do begin

   thisf=mdi_time2file(times[i],anytim(anytim(times[i])+24*3600.,/vms),/stan)

   nf=n_elements(thisf)
   for j=0,nf-1 do begin
      sock_fits,thisf[j],head=head,/nodat
      if n_elements(headarr) eq 0 then headarr=head else headarr=[headarr,head]
   endfor
stop

endfor

stop

















end
