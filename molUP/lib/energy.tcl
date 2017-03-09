package provide energy 1.0

proc molUP::firstProcEnergy {} {
    set oniomTrue [catch {exec egrep -m 1 "oniom" $molUP::path}]
    puts $oniomTrue
    if {$oniomTrue == "0"} {
        molUP::energy
    } else {
        molUP::energyNotONIOM
    }
}

proc molUP::firstProcEnergyAll {} {
    set oniomTrue [catch {exec egrep -m 1 "oniom" $molUP::path}]
    puts $oniomTrue
    if {$oniomTrue == "0"} {
        molUP::energyAll
    } else {
        molUP::energyNotONIOMAll
    }
}


proc molUP::energyNotONIOM {} {
    set energies [exec egrep {SCF Done:  E|Optimized Parameters} $molUP::path]
    set lines [split $energies \n]

    variable listEnergies {}
    variable listEnergiesOpt {}
    variable listEnergiesNonOpt {}
	
    foreach line $lines {
		lassign $line column1 column2 column3 column4 column5 column6 column7 column8 value
		
        if {$column1 == "SCF"} {
            lappend molUP::listEnergies $column5
		} elseif {[regexp {Non-Optimized} $line -> optimizedLine]} {
			lappend molUP::listEnergies "nonoptstructure"
		} elseif {[regexp {Optimized} $line -> optimizedLine]} {
			lappend molUP::listEnergies "optstructure"
		}
	}

    ## Search for optimized strcutures
    set optEnergy [lsearch -all $molUP::listEnergies "*optstructure"]
    set nonOptEnergy [lsearch -all $molUP::listEnergies "nonoptstructure"]

    if {$optEnergy == "" && $nonOptEnergy == ""} {
        #Ignore and plot no graph  
        molUP::guiError "No optimized structure was found.\nThe last structure was loaded instead." "No optmimized structure"
    } else {

        set structure 1
        foreach strut $optEnergy {
            set energy [lindex $molUP::listEnergies [expr $strut - 1]]
            set list [list "$structure" "$energy"]

            lappend molUP::listEnergiesOpt $list

            incr structure
        }

        foreach a $nonOptEnergy {
            set b [lsearch $optEnergy $a]
            lappend molUP::listEnergiesNonOpt [expr $b + 1]
        }

        molUP::drawGraph 

    }

}

proc molUP::energyNotONIOMAll {} {
    set energies [exec egrep {SCF Done:  E|Optimized Parameters} $molUP::path]
    set lines [split $energies \n]

    variable listEnergies {}
    variable listEnergiesOpt {}
    variable listEnergiesNonOpt {}
	
    foreach line $lines {
		lassign $line column1 column2 column3 column4 column5 column6 column7 column8 value
		
        if {$column1 == "SCF"} {
            lappend molUP::listEnergies $column5
		} else {

        }
	}

    ## Search for optimized strcutures

    set structure 1
    foreach strut $molUP::listEnergies {
        set list [list "$structure" "$strut"]

        lappend molUP::listEnergiesOpt $list

        incr structure
    }

    molUP::drawGraph 
}


proc molUP::energy {} {

    ## Get All energies
    set energies [molUP::gettingEnergy $molUP::path]

    ## Optimized Energies
	set lines [split $energies \n]

    ## Variable containing the list of energies for all structures
    variable listEnergies {}
    variable listEnergiesOpt {}
    variable listEnergiesNonOpt {}
	
    foreach line $lines {
		lassign $line column1 column2 column3 column4 column5 column6 column7 column8 value

        if {$value == "******************"} {
            set value 999999999999999999
        } else {}
		
        if {$column3 == 1} {
            lappend molUP::listEnergies $value
		} elseif {$column3 == 2} {
			lappend molUP::listEnergies $value
		} elseif {$column3 == 3} {
			lappend molUP::listEnergies $value
		} elseif {[regexp {Non-Optimized} $line -> optimizedLine]} {
			lappend molUP::listEnergies "nonoptstructure"
		} elseif {[regexp {Optimized} $line -> optimizedLine]} {
			lappend molUP::listEnergies "optstructure"
		}

	}

    ## Search for optimized strcutures
    set optEnergy [lsearch -all $molUP::listEnergies "*optstructure"]
    set nonOptEnergy [lsearch -all $molUP::listEnergies "nonoptstructure"]

    if {$optEnergy == "" && $nonOptEnergy == ""} {
        #Ignore and plot no graph  
        molUP::guiError "No optimized structure was found.\nThe last structure was loaded instead." "No optmimized structure"
    } else {

        set structure 1
        foreach strut $optEnergy {
            set highEnergy [lindex $molUP::listEnergies [expr $strut - 2]]
            set lowEnergy [expr [lindex $molUP::listEnergies [expr $strut - 1]] - [lindex $molUP::listEnergies [expr $strut - 3]]]
            set totalEnergy [expr $highEnergy + $lowEnergy]
            set list [list "$structure" "$totalEnergy" "$highEnergy" "$lowEnergy"]

            lappend molUP::listEnergiesOpt $list

            incr structure
        }

        foreach a $nonOptEnergy {
            set b [lsearch $optEnergy $a]
            lappend molUP::listEnergiesNonOpt [expr $b + 1]
        }

        molUP::drawGraph 

    }
}

proc molUP::energyAll {} {

    ## Get All energies
    set energies [molUP::gettingEnergy $molUP::path]

    ## Optimized Energies
	set lines [split $energies \n]

    ## Variable containing the list of energies for all structures
    variable listEnergies {}
    variable listEnergiesOpt {}
    variable listEnergiesNonOpt {}
	
    foreach line $lines {
		lassign $line column1 column2 column3 column4 column5 column6 column7 column8 value

        if {$value == "******************"} {
            set value 999999999999999999
        } else {}
		
        if {$column3 == 1} {
            lappend molUP::listEnergies $value
		} elseif {$column3 == 2} {
			lappend molUP::listEnergies $value
		} elseif {$column3 == 3} {
			lappend molUP::listEnergies $value
            lappend molUP::listEnergies "newStruct"
		} elseif {[regexp {Non-Optimized} $line -> optimizedLine]} {
			#lappend molUP::listEnergies "nonoptstructure"
		} elseif {[regexp {Optimized} $line -> optimizedLine]} {
			#lappend molUP::listEnergies "optstructure"
		}

	}

    ## Search for optimized strcutures
    set optEnergy [lsearch -all $molUP::listEnergies "newStruct"]

    set structure 1
    foreach strut $optEnergy {
        set highEnergy [lindex $molUP::listEnergies [expr $strut - 2]]
        set lowEnergy [expr [lindex $molUP::listEnergies [expr $strut - 1]] - [lindex $molUP::listEnergies [expr $strut - 3]]]
        set totalEnergy [expr $highEnergy + $lowEnergy]
        set list [list "$structure" "$totalEnergy" "$highEnergy" "$lowEnergy"]

        lappend molUP::listEnergiesOpt $list

        incr structure
    }

    molUP::drawGraph 
}


proc molUP::gettingEnergy {File} {
        set energies [exec egrep {low   system:  model energy:|high  system:  model energy:|low   system:  real  energy:|ONIOM: extrapolated energy|Optimized Parameters} $File]
        return $energies
}

proc molUP::drawGraph {} {
    #### Create a new tab - Energies
    set molID [molinfo top]
	$molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs add [frame $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6] -text "Energies"

    place [ttk::frame $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph \
            -width 380 \
            -height 250 \
			] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 5 -y 5 -width 380 -height 250

    #pack [canvas $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph.area -background white -width 380 -height 250]

    place [ttk::button $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.savePS \
            -text "Save as vector image (PostScript)" \
            -style molUP.TButton \
            -command {molUP::savePS $molUP::topGui.frame0.major.mol[molinfo top].tabs.tabResults.tabs.tab6.graph}
            ] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 5 -y 260 -width 250 

    place [ttk::button $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.exportData \
            -text "Export data" \
            -style molUP.TButton \
            -command {molUP::exportEnergy}
            ] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 265 -y 260 -width 120 

    place [ttk::label $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.note \
		-style molUP.white.TLabel \
		-text {Red points (if available) correspond to non-optimized structure.} ] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 5 -y 290
    
    place [ttk::label $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.note1 \
		-style molUP.white.TLabel \
		-text {Zoom In: Drag the mouse     Zoom Out: Right or Middle -click} ] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 5 -y 305
 

    ## Create a list for each variable
    set structure {}
    set totalE {}
    set hlE {}
    set llE {}
    foreach list $molUP::listEnergiesOpt {
        lappend structure [lindex $list 0]
        lappend totalE [lindex $list 1]
        lappend hlE [lindex $list 2]
        lappend llE [lindex $list 3]
    }

    set xMax [expr [lindex [lsort -real -decreasing $structure] 0] + 1]
    set xMin [lindex [lsort -real -increasing $structure] 0]
    set xInt [expr [format %.0f [expr ($xMax - $xMin)/10]] + 1]

    set yMax [expr [lindex [lsort -real -decreasing $totalE] 0] + (([lindex [lsort -real -decreasing $totalE] 0] - [lindex [lsort -real -increasing $totalE] 0])*0.05)]
    set yMin [expr [lindex [lsort -real -increasing $totalE] 0] - (($yMax - [lindex [lsort -real -increasing $totalE] 0])*0.05)]
    set yInt [expr ($yMax - $yMin)/10]



    #set graph [::Plotchart::createXYPlot $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph.area [list $xMin $xMax $xInt] [list $yMin $yMax $yInt]]
    #$graph dataconfig total -type both -color blue -symbol dot -radius 2
    #foreach x $structure y $totalE {
    #    $graph plot total $x $y
    #    $graph bindlast total <1> {molUP::mouseClick}
    #}
    ##$graph plotlist total $structure $totalE 1
    #$graph yconfig -format %.5f
    #$graph ytext "Energy (hartree)"
    #$graph xtext "Reaction Coordinate"

    



    ## Draw the graph
    molUP::drawPlot $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph $structure $totalE "Energetic Profile" black 16 oval black black 5
    #molUP::addData $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph $structure $hlE oval red red 8
    #molUP::addData $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph $structure $llE oval blue blue 8

}

proc molUP::mouseClick {x y} {
    animate goto [expr [format %.0f $x] - 1]
}

proc molUP::firstStepReference {list} {
    variable firstStepRefList {}

    set firstLine [lindex $list 0]
    set numberEnegeries [expr [llength $firstLine] -1]

    foreach value $list {
        set a [lindex $value 0]
        for {set index 1} { $index <= $numberEnegeries } { incr index } {
            set energy [expr ([lindex $value $index] - [lindex $firstLine $index]) * 627.509]
            lappend a $energy
        }
        lappend molUP::firstStepRefList $a
    }

    return $molUP::firstStepRefList
}

proc molUP::drawFirstStepRef {} {
    set molID [molinfo top]
    destroy $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph

    place [ttk::frame $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph \
            -width 380 \
            -height 250 \
			] -in $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6 -x 5 -y 5 -width 380 -height 250

    
    molUP::firstStepReference $molUP::listEnergiesOpt

    ## Create a list for each variable
    set structure {}
    set totalE {}
    set hlE {}
    set llE {}
    foreach list $molUP::firstStepRefList {
        lappend structure [lindex $list 0]
        lappend totalE [lindex $list 1]
        lappend hlE [lindex $list 2]
        lappend llE [lindex $list 3]
    }

    ## Draw the graph
    molUP::drawPlot $molUP::topGui.frame0.major.mol$molID.tabs.tabResults.tabs.tab6.graph $structure $totalE "Energetic Profile" black 16 oval blue black 8

}


proc molUP::savePS {pathname} {
        set fileTypes {
                {{PostScript (.ps)}       {.ps}        }
        }
        set path [tk_getSaveFile -filetypes $fileTypes -defaultextension ".ps" -title "Save image" -initialfile "energy.ps"]

        if {$path != ""} {
            $pathname.plotBackground.area.canvas postscript -file [list $path]
        } else {}
}

proc molUP::exportEnergy {args} {
        set fileTypes {
                {{Text (.txt)}       {.txt}        }
        }
        set path [tk_getSaveFile -filetypes $fileTypes -defaultextension ".txt" -title "Export energy values" -initialfile "energy.txt"] 

        if {$path != ""} {
            set file [open $path w]
            set numberColumns [llength [lindex $molUP::listEnergiesOpt 0]]

            if {$numberColumns == 4} {
                puts $file "Energy of optimized structures (Units: Hartree)\nData exported by molUP - a VMD plugin\nStructure \t Total Energy \t High level Energy \t Low level Energy"
                foreach value $molUP::listEnergiesOpt {
                    puts $file "[lindex $value 0] \t\t [lindex $value 1] \t [lindex $value 2] \t [lindex $value 3]"
                }
            } else {
                puts $file "Energy of optimized structures (Units: Hartree)\nStructure \t Energy"
                foreach value $molUP::listEnergiesOpt {
                    puts $file "[lindex $value 0] \t\t [lindex $value 1]"
                }
            }

            close $file

        } else {}
}