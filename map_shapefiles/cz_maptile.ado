*! 31jan2014, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_cz
program define _maptile_cz
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map var(varname) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
					stateoutline ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m cz using `"`shapefolder'/cz_database_clean"', nogen
		exit
	}
	
	if ("`map'"!="") {
	
		if ("`stateoutline'"!="") {
			cap confirm file `"`shapefolder'/state_coords_clean.dta"'
			if (_rc==0) local polygon polygon(data(`"`shapefolder'/state_coords_clean"') ocolor(black) osize(thin ...))
			else if (_rc==601) {
				di as error `"stateoutline option requires 'state_coords_clean.dta' in the shapefolder"'
				exit 198				
			}
			else {
				error _rc
				exit _rc
			}
		}

		spmap `var' using `"`shapefolder'/cz_coords_clean"' `map_restriction', id(id) ///
			`legopt' legend(pos(5) size(*1.8)) ///
			clmethod(custom) ///
			clbreaks(`min' `clbreaks' `max') ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vvthin ...) nds(vvthin) ///
			`polygon' ///
			`spopt'
			
		* Save graph
		if `"`savegraph'"'!="" {
			* check file extension using a regular expression
			if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
			
			* deal with different filetypes appropriately
			if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
			else if inlist(`"`graphextension'"',".ps",".eps") graph export `"`savegraph'"', mag(`=round(100*`resolution')') `replace'
			else if (`"`graphextension'"'==".png") graph export `"`savegraph'"', width(`=round(3200*`resolution')') `replace'
			else if (`"`graphextension'"'==".tif") graph export `"`savegraph'"', width(`=round(1600*`resolution')') `replace'
			else graph export `"`savegraph'"', `replace'
		}
		
	}
	
end
