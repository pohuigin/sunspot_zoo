pro extract_hmi_regions, date

	; Download SDO/HMI continuum and magnetogram fits files for 00:30 UT on date

	mag_files = vso_search( date, instr='hmi', physobs='LOS_magnetic_field' )
	int_files = vso_search( date, instr='hmi', physobs='intensity')

	; Just download the first file of the day

	status = vso_get( mag_files[ 0 ], filename = mag_filename )
	status = vso_get( int_files[ 0 ], filename = int_filename )

	; Read in files

	fits2map, mag_filename, mag_map
	fits2map, int_filename, int_map

	; Rotate images so the north up - not sure if this always has to be done

	mag_map = rot_map( mag_map, 180 )
	int_map = rot_map( int_map, 180 )

	; Now get NOAA ARs - need to use date before to get positions right
	
	prev_date = anytim( anytim( date ) - 24. * 60. * 60, /vms )
	nar = get_nar( prev_date, limit = 1, /unique )

        ; Plot maps to make sure they look ok

        !p.multi = [ 0, 2, 1 ]
	window, xsize = 800, ysize = 500

        loadct, 0
        plot_map, mag_map, dmin = -1000, dmax = 1000
        oplot_nar, nar
	
	loadct, 3 	; use aia_lct to load yellow color table
	plot_map, int_map
	oplot_nar, nar

	; We assume that the images are close in time to 00:30 UT. 
	; The right way of doing this is to differentially rotate the NAR co-ordinates to the image time

	; Now extract region maps

	for i = 0, n_elements( nar ) - 1 do begin

		print, 'Extracting NOAA '+ arr2str( nar[ i ].noaa, /trim )

		xrange = [ nar[ i ].x - 200,  nar[ i ].x + 200. ] 	
		yrange = [ nar[ i ].y - 200,  nar[ i ].y + 200. ]

		sub_map, mag_map, smag_map, xrange = xrange, yrange = yrange
		sub_map, int_map, sint_map, xrange = xrange, yrange = yrange

		loadct, 0 
		plot_map, smag_map, grid = 10., dmin = -1000, dmax = 1000
		oplot_nar, nar
		;x2png, 'hmi_mag_' + arr2str( nar[ i ].noaa, /trim ) + '_' + date2file( date ) + '.png'

		loadct, 3	; should use yellow colour table
		plot_map, sint_map, grid = 10.
		oplot_nar, nar
         	;x2png, 'hmi_int_' + arr2str( nar[ i ].noaa, /trim ) + '_' + date2file( date ) + '.png'

		ans = ''
		read, 'OK (y/n): ', ans

	endfor


end
