;;____________________________
;
;;   SETUP AND HOUSEKEEPING
;;____________________________

breed [ parties party ]

globals [
  log-file-name
  run-number
  total-votes
  max-voteshare            ; largest vote share on any patch
  mean-voterx              ; mean voter x-coordinate
  mean-votery              ; mean voter y-coordinate

  cycle
  election                 ; election number

  n-parties                ; total number of parties that competed in the previous election
  voter-misery             ; mean quadratic Euclidean voter distance from closest party
  mean-eccentricity        ; mean Euclidean distance of parties from (mean-voterx, mean-votery)
  enp                      ; effective number of parties = 1/(sum of squared party vote shares)

  mean-party-policy-loss   ; mean ideal policy point loss for all of the parties
  mean-party-policy-shift  ; mean ideal policy shift for all of the parties
  mean-party-phi           ; mean phi for all of the parties

  rule-number              ; rule number
  rule-list                ; list of available decision rules
  rule-voteshare           ; list of voteshares won by the set of parties using each rule
  rule-pcount              ; number of parties using rule
  rule-eccent              ; list of the mean eccentricities of all parties using each rule
  rule-loss                ; mean policy loss of party leaders using each rule
  rule-delta               ; mean policy movement of party leaders using each rule
]

parties-own [
  rule                      ; party's parameterized decision rule
  species                   ; party's decision rule species

                     ; decision rule parameters
  speed                     ; distance each party moves per tick
  comfort-kappa             ; comfort threshold - implement rule iff fitness below this
  neighborhood-eta          ; radius from party postion of local neighborhood
  phi                       ; mixing parameter that specifies the relative importance of the ideal-point loss

                     ; indicators
  mysize                    ; current party size
  old-x                     ; x-coordinate of my position at previous election
  old-y                     ; y-coordinate of my position at previous election
  policy-shift              ; policy distance moved since birth
  age                       ; number of elections survived since birth
  fitness                   ; party's evolutionary fitness
  eccentricity              ; party's Euclidean distance from (mean-voterx, mean-votery)
  valence
  ideal-x                   ; party's ideal position in the x dimension
  ideal-y                   ; party's ideal position in the y dimension
  utiles                    ; party's utility, balancing vote share and policy preferences
  old-utiles                ; utiles as of the most recent update
  ideal-point-loss          ; quadratic distance between leader's ideal position and party position

                     ; rule-specific variables
  prey                      ; for predators:  party I am thinking of attacking
  best-x                    ; for explorers:  explored x-coordinate with highest utility during campaign
  best-y                    ; for explorers:  explored y-coordinate with highest utility during campaign
  best-utiles               ; for explorers:  highest-utility found during campaign
]

patches-own [
  votes                     ; number of voters on patch
  vote-share                ; proportion of total voters on patch
  closest-party             ; party with smallest Euclidean distance from patch
  misery                    ; quadratic distance from closest party, weighted by patch's vote share
  best-party
]

to setup
  clear-all
  file-close-all

  set election 0

  random-pop
  ;; NEW: Hard-coded file path
  set run-number get-next-run-number

  let base-path "C:/Users/jihun/OneDrive/바탕 화면/시뮬레이션 결과"

  ;; 이제 'run-number' 변수를 사용해 로그 파일 이름을 만듭니다.
  set log-file-name (word base-path "/" "run-" run-number "-log.csv")

  if (file-exists? log-file-name) [
    file-delete log-file-name
  ]


  file-open log-file-name
  ;; NEW: Write the comprehensive header for the unified file
  file-print (word
    "run-number,"
    "election,"       ; 선거
    "event_type,"     ; 이벤트 유형 (system, party_status, birth, death)
    "who,"            ; 정당 ID
    "rule,"           ; 정당 규칙
    "species,"        ; 정당 종
    "phi,"            ; 정당 phi 값
    "age,"            ; 정당 연령
    "xcor,"           ; 정당 x좌표
    "ycor,"           ; 정당 y좌표
    "mysize,"         ; 정당 득표수
    "vote_share,"     ; 정당 득표율
    "fitness,"        ; 정당 적합도
    "ideal_point_loss," ; 정당 정책 손실
    "valence,"
    "n_parties,"      ; (시스템) 총 정당 수
    "enp,"            ; (시스템) 유효 정당 수
    "voter-misery,"   ; (시스템) 유권자 불만
    "mean_eccentricity," ; (시스템) 평균 이심률
    "mean_party_policy_loss," ; (시스템) 평균 정책 손실
    "mean_party_policy_shift," ; (시스템) 평균 정책 이동
    "mean_party_phi,"  ; (시스템) 평균 phi
    "param_x_mean1,"
    "param_y_mean1,"
    "param_sd_1,"
    "param_votes1,"
    "param_x_mean2,"
    "param_y_mean2,"
    "param_sd_2,"
    "param_votes2"
  )

  file-close
  ;; END NEW SECTION

  if (endogenous-birth = false) [set misery-alpha 0 set misery-beta 0]

  set rule-list (list

  ;; Sticker (comfort-kappa=000, phi=10, 알파벳 36개)
  "S00010a" "S00010b" "S00010c" "S00010d" "S00010e" "S00010f"
  "S00010g" "S00010h" "S00010i" "S00010j" "S00010k" "S00010l"
  "S00010m" "S00010n" "S00010o" "S00010p" "S00010q" "S00010r"
  "S00010s" "S00010t" "S00010u" "S00010v" "S00010w" "S00010x"
  "S00010y" "S00010z" "S00010aa" "S00010ab" "S00010ac" "S00010ad"
  "S00010ae" "S00010af" "S00010ag" "S00010ah" "S00010ai" "S00010aj"

  ;; Aggregator (comfort-kappa=000, phi, 알파벳 a~f 반복, 총 36개)
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"
  "A00000a" "A00002b" "A00004c" "A00006d" "A00008e" "A00010f"

  ;; Hunter (comfort-kappa × phi, 36개)
  "H00300" "H00302" "H00304" "H00306" "H00308" "H00310"
  "H01000" "H01002" "H01004" "H01006" "H01008" "H01010"
  "H01500" "H01502" "H01504" "H01506" "H01508" "H01510"
  "H02000" "H02002" "H02004" "H02006" "H02008" "H02010"
  "H03000" "H03002" "H03004" "H03006" "H03008" "H03010"
  "H04000" "H04002" "H04004" "H04006" "H04008" "H04010"

  ;; Predator (comfort-kappa × phi, 36개)
  "P00300" "P00302" "P00304" "P00306" "P00308" "P00310"
  "P01000" "P01002" "P01004" "P01006" "P01008" "P01010"
  "P01500" "P01502" "P01504" "P01506" "P01508" "P01510"
  "P02000" "P02002" "P02004" "P02006" "P02008" "P02010"
  "P03000" "P03002" "P03004" "P03006" "P03008" "P03010"
  "P04000" "P04002" "P04004" "P04006" "P04008" "P04010"

  ;; Explorer (comfort-kappa × phi, 36개)
  "E00300" "E00302" "E00304" "E00306" "E00308" "E00310"
  "E01000" "E01002" "E01004" "E01006" "E01008" "E01010"
  "E01500" "E01502" "E01504" "E01506" "E01508" "E01510"
  "E02000" "E02002" "E02004" "E02006" "E02008" "E02010"
  "E03000" "E03002" "E03004" "E03006" "E03008" "E03010"
  "E04000" "E04002" "E04004" "E04006" "E04008" "E04010"
)

  set rule-number n-values length(rule-list) [i -> i]
  set rule-voteshare n-values length(rule-list) [i -> 0]
  set rule-pcount n-values length(rule-list) [i -> 0]
  set rule-eccent n-values length(rule-list) [i -> -1]
  set rule-loss n-values length(rule-list) [i -> -1]
  set rule-delta n-values length(rule-list) [i -> -1]

  create-parties 1
  ask parties [
    set fitness 1
    set heading random-float 360
    jump random-float 30
    set old-x xcor
    set old-y ycor
    set age 0
    set size 2
    random-pick
    load-rule-parameters
    color-myself
    set ideal-x xcor
    set ideal-y ycor
    set old-utiles 0

    initialize-party-log
  ]
  ;; every run starts with a single party, which has a random position and rule picked from the rule list

  ask patches [
      let x1 (pxcor - x-mean1) / sd-1
      let y1 (pycor - y-mean1) / sd-1
      set votes votes1 * exp (-0.5 * ( x1 ^ 2 + y1 ^ 2)) / (2 * pi * sd-1 ^ 2)
        ;; votes1, x_mean1, y_mean1, sd_1 = votes, mean and standard deviation of subpopulation 1, read from interface
        ;; each patch's votes arising from subpopulation 1 =  votes1 * bivariate normal density with mean1, sd_1, rho = 0

      if (votes2 > 0)[
      let x2 (pxcor - x-mean2) / sd-2
      let y2 (pycor - y-mean2) / sd-2
      set votes votes + votes2 * exp (-0.5 * ( x2 ^ 2 + y2 ^ 2)) / (2 * pi * sd-2 ^ 2)]
        ;; add votes to each patch from subpopulation 2, calculated as above

      if (votes3 > 0)[
      let x3 (pxcor - x-mean3) / sd-3
      let y3 (pycor - y-mean3) / sd-3
      set votes votes + votes3 * exp (-0.5 * ( x3 ^ 2 + y3 ^ 2)) / (2 * pi * sd-3 ^ 2)]
        ;; add votes to each patch from subpopulation 3, calculated as above
      ]

  set total-votes sum [ votes ] of patches
  type "Total votes at all locations = " type round(total-votes)
        ;; add total of votes on all patches and output this to the command window

  ask patches [set vote-share votes / total-votes]
      ;calculate each patch's vote share

  set mean-voterx sum [ pxcor * vote-share ] of patches
  set mean-votery sum [ pycor * vote-share ] of patches
  type "   Mean voter x = " type round(mean-voterx)
  type "   Mean voter y = " print round(mean-votery)
      ;; calculate center (mean) of voter distribution on each dimension as sum of (patch positions weighted by vote share)
      ;; output this to the command window

  set max-voteshare max [ vote-share ] of patches
  ask patches [set pcolor scale-color gray vote-share 0 max-voteshare ]
      ;; color patches red with density proportional to vote shares

  update-support
      ;; ask voters to choose closest party and calculate relative success of different rules
  update-utility
      ;; ask party leaders to calculate their utility based on their position and vote share
end

;; NEW: This procedure reads a counter file, reports the current number,
;; and writes the *next* number back to the file.
;; WARNING: This will NOT work with "Run in parallel"!
to-report get-next-run-number
  let base-path "C:/Users/jihun/OneDrive/바탕 화면/시뮬레이션 결과"
  let counter-file (word base-path "/" "run_counter.txt")

  let current-run-number 0

  ;; 1. Read the counter file if it exists
  if (file-exists? counter-file) [
    file-open counter-file
    if (not file-at-end?) [
      set current-run-number file-read
    ]
    file-close
  ]

  ;; 2. Delete the old counter file
  if (file-exists? counter-file) [
    file-delete counter-file
  ]

  ;; 3. Write the *next* run number back to the file
  file-open counter-file
  file-print (current-run-number + 1)
  file-close

  ;; 4. Report the *current* run number
  report current-run-number
end


to random-pop
  set x-mean1 precision (random-float 10) 2
  set x-mean2 precision (0 - random-float 10) 2
  set y-mean1 precision (random-float 10) 2
  set y-mean2 precision (0 - random-float 10) 2

  set sd-1 precision (3 + random-float 5) 2
  set sd-2 precision (3 + random-float 5) 2
end

;;____________________________
;
;;   PARTY DYNAMICS
;;____________________________

to stick
      ;; do nothing
end

to aggregate
   if (mysize > 0)                                                 ; maintain current position if zero supporters, else ...
   [   let xbar (sum [votes * pxcor] of patches with [closest-party = myself] / mysize)
       let ybar (sum [votes * pycor] of patches with [closest-party = myself] / mysize)
       let xdest (phi * ideal-x) + (1 - phi) * xbar                ; find a policy destination that balances your ideal point
       let ydest (phi * ideal-y) + (1 - phi) * ybar                ; with the mean position of current party supporters
       facexy xdest ydest
       let dist distancexy xdest ydest
       ifelse (dist >= speed) [jump speed] [setxy xdest ydest]]    ; if you will not overshoot (xbdest, ydest), jump "speed" towards this
end

to hunt
   ifelse (utiles > old-utiles) [jump speed]
   [set heading heading + 90 + random-float 180  jump speed]       ; move "speed" in same heading if last move increased UTILITY, else browse
   set old-utiles utiles                                           ; remember utility and size for next cycle
end

to sat-hunt
   ifelse (mysize / total-votes < comfort-kappa) [hunt] [stick]
end

to predate
    set prey max-one-of parties [mysize]
    let xdest (phi * ideal-x) + (1 - phi) * [xcor] of prey
    let ydest (phi * ideal-y) + (1 - phi) * [ycor] of prey
       facexy xdest ydest                                          ; find a policy destination that balances your ideal point
       let dist distancexy xdest ydest                             ; with the  position of the largest party
       ifelse (dist >= speed) [jump speed] [setxy xdest ydest]     ; if you will not overshoot (xdest, ydest), jump "speed" towards this
end

to sat-predate
  ifelse (mysize / total-votes < comfort-kappa) [predate] [stick]
end

to explore
  if (utiles > best-utiles) [set best-x xcor set best-y ycor set best-utiles utiles]
      ;; if you found a position with more UTILES than your previous best-utiles, update your best position
  ifelse (remainder cycle campaign-ticks != 0)
     [setxy old-x old-y set heading random-float 360 jump random-float neighborhood-eta]
     [if (best-utiles > old-utiles) [setxy best-x best-y] set best-utiles 0 ]
end

to sat-explore
  ifelse (mysize / total-votes < comfort-kappa) [explore] [stick]
end

;;____________________________
;;
;;   MAIN CONTROL SUBROUTINES
;;____________________________

to update-support
  ask patches [set closest-party min-one-of parties [distance myself]]
      ;; patches find their closest party
  ask patches [set best-party max-one-of parties                                                   ;;the valence model enters here ******
      [ valence-lambda * valence - (1 - valence-lambda) * ((distance myself) ^ 2)]]                                                ;*****
      ;; patches find their "best" party - the one that maximizes their valence-weighted quadratic utility                         ******
      ;; NB distances and thus valence are scaled in NetLogo patch units                                                           ******
      ;; i.e. a distance differential of 1 sd = 10 units from the ideal point is balanced when lambda = 0.5                        ******
      ;; by a valence differential of 100
      ;; setting valence-lamda = 0 gives the no-valence model                                                                      ******
  ask parties [set mysize sum [votes] of patches with [best-party = myself]]                                                       ;*****
      ;; each party sums the votes on patches for which it is the best party                                                       ******
end

to update-utility
  ask parties [
    let scale 0.05
    set ideal-point-loss 0 - (distancexy ideal-x ideal-y ^ 2) / 100
    set utiles 1 + (phi * scale * ideal-point-loss) + ((1 - phi) * mysize / total-votes)
        ;;phi (<= 1) is like the alpha parameter, but balances votes and policy
        ;;phi = 1 implies ideal point loss is all important;
        ;;the scale parameter is an "exchange rate", needed because votes and policy are measured in different units.
  ]
end

to calculate-election-results
  set election election + 1
  update-party-measures
  update-rule-measures
  measure-enp
  measure-eccentricity
  measure-misery

  ;; MODIFIED: Log data *before* death and birth
  log-election-data

  party-death
  party-birth
end

to update-party-measures
  ask parties [
      set fitness fitness-alpha * fitness + (1 - fitness-alpha) * mysize / total-votes
                 ;; parties recursively update their fitness as: (alpha)*(previous fitness) + (1-alpha)*(current vote share)
      set policy-shift sqrt((xcor - old-x) ^ 2 + (ycor - old-y) ^ 2)
      set age age + 1 set old-x xcor set old-y ycor
  ]

  set n-parties count parties
  set mean-party-policy-loss sum [ideal-point-loss] of parties / n-parties
  set mean-party-policy-shift mean [policy-shift] of parties
  set mean-party-phi mean [phi] of parties
end

to update-rule-measures
  (foreach rule-number rule-list [ [i r] ->
      set rule-voteshare replace-item i rule-voteshare sum [mysize / total-votes] of parties with [rule = r]
          ;; calculate the current support level of all parties using each rule

      set rule-pcount replace-item i rule-pcount count parties with [rule = r]
          ;; count the number of parties using each rule

      ifelse (sum [mysize] of parties with [rule = r] > 0)
        [
        set rule-eccent replace-item i rule-eccent mean [eccentricity] of parties with [rule = r]
        set rule-loss replace-item i rule-loss mean [ideal-point-loss] of parties with [rule = r]
        set rule-delta replace-item i rule-delta mean [policy-shift] of parties with [rule = r]
        ]
          ;;calculate the mean of eccentricity, policy loss and policy shift of all parties using each rule

        [
        set rule-eccent replace-item i rule-eccent -1
        set rule-loss replace-item i rule-loss -1
        set rule-delta replace-item i rule-delta -1
        ]
          ;;these measures have no meaning when no party uses a rule
    ])
end

to measure-enp
  set enp (total-votes ^ 2) / (sum [mysize ^ 2] of parties)
     ;; calculate the enp of the system
end

to measure-eccentricity
  ask parties [set eccentricity sqrt ((xcor - mean-voterx) ^ 2 + (ycor - mean-votery) ^ 2) / 10]
     ;; calculate each party's eccentricity, its Euclidean distance from the center of the voter distribution
  set mean-eccentricity mean [eccentricity] of parties
     ;; calculate the mean eccentricity of all parties in the system
end

to measure-misery
   ask patches [set misery misery-alpha * misery + (1 - misery-alpha) * ((distance closest-party ^ 2) / 100) * vote-share]
   set voter-misery sum [misery] of patches
      ;; patch misery is misery at t-1, updated by mean quadratic Euclidean distance of patch from closest party,
      ;; weighted by patch vote share
      ;; mean voter "misery" is thus updated mean quadratic Euclidean distance of each voter from his/her closest party
end

to party-death
   ask parties [if (fitness < survival-threshold and count parties > 2)
       [
          ;; MODIFIED: Log all available data for the dying party
          file-open log-file-name
          file-print (word
            run-number ","
            election ","
            "death,"          ; event_type
            who ","
            (word """" rule """") ","
            species ","
            phi ","
            age ","
            precision xcor 4 ","
            precision ycor 4 ","
            mysize "," precision (mysize / total-votes) 4 ","
            precision fitness 4 "," precision ideal-point-loss 4 ","
            valence ","
            n-parties ","
            precision enp 4 ","
            precision voter-misery 4 ","
            precision mean-eccentricity 4 ","
            precision mean-party-policy-loss 4 ","
            precision mean-party-policy-shift 4 ","
            precision mean-party-phi 4 ","
            x-mean1 "," y-mean1 "," sd-1 "," votes1 ","
            x-mean2 "," y-mean2 "," sd-2 "," votes2
          )
          file-close
          ;; END MODIFIED SECTION

          die
          ask patches [set closest-party min-one-of parties [distance myself]]
       ]]
end

to party-birth
  ifelse (endogenous-birth = true)
    [ ask one-of patches with [distancexy 0 0 < 30]
      [ if (random-float 1 < (misery-beta * misery * 1000))
        [sprout-parties 1 [initialize-party initialize-party-log] ]]] ; MODIFIED
    [ create-parties 1 [set heading random-float 360 jump random-float 30 initialize-party initialize-party-log] ] ; MODIFIED
end

;; NEW: Helper procedure to log the birth of a party
;; NEW: Helper procedure to log the birth of a party
to initialize-party-log
  ;; 'myself' context (called by the new party)
  file-open log-file-name
  file-print (word
    run-number ","
    election ","
    "birth,"          ; event_type
    who ","
    (word """" rule """") ","
    species ","
    phi ","
    age ","
    precision xcor 4 ","
    precision ycor 4 ","
    0 "," 0 "," ; mysize, voteshare (not yet calculated)
    precision fitness 4 "," 0 "," ; fitness (is set), ideal-point-loss (not yet set)
    valence ","
    n-parties ","
    precision enp 4 ","
    precision voter-misery 4 ","
    precision mean-eccentricity 4 ","
    precision mean-party-policy-loss 4 ","
    precision mean-party-policy-shift 4 ","
    precision mean-party-phi 4 ","
    x-mean1 "," y-mean1 "," sd-1 "," votes1 ","
    x-mean2 "," y-mean2 "," sd-2 "," votes2
  )
  file-close
end

to initialize-party
  ifelse (count parties = 0) [set fitness 1] [set fitness 1 / count parties]
  set heading random-float 360
  set old-x xcor
  set old-y ycor
  set age 0
  set size 1.5

  random-pick
  load-rule-parameters
  color-myself

  ;; (기존 'if (birth-death-file = true) [...]' 블록을 여기서 삭제합니다.)
end

to random-pick
    set rule one-of rule-list
    ;; randomly pick a rule from the rule list
end

to load-rule-parameters                    ; set parameters of your decision rule by reading the relevant parts of your rule name
  set species first rule
  set comfort-kappa (read-from-string substring rule 1 4) / 100
  set phi (read-from-string substring rule 4 6) / 10
  set speed 1
  set neighborhood-eta 6
  set valence one-of [25 50 75]
  set size 1 + valence / 50
end

to color-myself
  if (species = "S") [set color yellow]
  if (species = "A") [set color lime]
  if (species = "H") [set color violet]
  if (species = "P") [set color red]
  if (species = "E") [set color blue]
end

to adapt
  if (species = "S") [stick]
  if (species = "A") [aggregate]
  if (species = "H") [sat-hunt]
  if (species = "P") [sat-predate]
  if (species = "E") [sat-explore]
end


;; NEW: Helper procedure to log system and party data each election
to log-election-data
  file-open log-file-name  ; Open for appending

  ;; 1. Log System Statistics (event_type = "system")
  file-print (word
    run-number ","
    election ","
    "system,"         ; event_type
    "NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA," ; 12 NA for party columns
    n-parties ","
    precision enp 4 ","
    precision voter-misery 4 ","
    precision mean-eccentricity 4 ","
    precision mean-party-policy-loss 4 ","
    precision mean-party-policy-shift 4 ","
    precision mean-party-phi 4 ","
    x-mean1 "," y-mean1 "," sd-1 "," votes1 ","
    x-mean2 "," y-mean2 "," sd-2 "," votes2
  )

  ;; 2. Log Individual Party Status (event_type = "party_status")
  ask parties [
    file-print (word
      run-number ","
      election ","
      "party_status,"   ; event_type
      who ","
      (word """" rule """") ","
      species ","
      phi ","
      age ","
      precision xcor 4 ","
      precision ycor 4 ","
      mysize ","
      precision (mysize / total-votes) 4 ","
      precision fitness 4 ","
      precision ideal-point-loss 4 ","
      valence ","
      n-parties ","
      precision enp 4 ","
      precision voter-misery 4 ","
      precision mean-eccentricity 4 ","
      precision mean-party-policy-loss 4 ","
      precision mean-party-policy-shift 4 ","
      precision mean-party-phi 4 ","
      x-mean1 "," y-mean1 "," sd-1 "," votes1 ","
      x-mean2 "," y-mean2 "," sd-2 "," votes2
    )
  ]

  file-close
end




;;____________________________
;
;;   MAIN CONTROL ROUTINE
;;____________________________

to go
  repeat campaign-ticks
  [
    set cycle cycle + 1
    ask parties [adapt]
    update-support
    update-utility
    if (remainder cycle campaign-ticks = 0 and cycle != 0) [calculate-election-results]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
0
10
67
43
Setup
set run-number 0\nsetup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
72
10
135
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
0
53
64
98
N parties
n-parties
0
1
11

MONITOR
63
53
121
98
Misery
voter-misery
2
1
11

MONITOR
119
53
198
98
Eccentricity
mean-eccentricity
2
1
11

MONITOR
0
97
58
142
ENP
enp
2
1
11

SLIDER
0
166
173
199
misery-alpha
misery-alpha
0
1
0.51
.01
1
NIL
HORIZONTAL

SLIDER
0
200
173
233
misery-beta
misery-beta
0
1
0.3
.01
1
NIL
HORIZONTAL

SWITCH
0
233
174
266
endogenous-birth
endogenous-birth
0
1
-1000

SWITCH
0
265
153
298
birth-death-file
birth-death-file
0
1
-1000

SLIDER
0
299
173
332
fitness-alpha
fitness-alpha
0
.99
0.7
.01
1
NIL
HORIZONTAL

SLIDER
0
331
173
364
survival-threshold
survival-threshold
0
1.0
0.03
.01
1
NIL
HORIZONTAL

SLIDER
0
366
173
399
campaign-ticks
campaign-ticks
100
1000
500.0
100
1
NIL
HORIZONTAL

MONITOR
0
399
140
444
Mean party policy loss
mean-party-policy-loss
2
1
11

MONITOR
0
444
140
489
Mean party policy shift
mean-party-policy-shift
2
1
11

MONITOR
0
489
95
534
Mean party phi
mean-party-phi
2
1
11

SLIDER
210
448
383
481
votes1
votes1
0
1000000
1000000.0
1000
1
NIL
HORIZONTAL

SLIDER
210
480
383
513
votes2
votes2
0
1000000
1000000.0
1000
1
NIL
HORIZONTAL

SLIDER
210
512
383
545
votes3
votes3
0
1000000
0.0
1000
1
NIL
HORIZONTAL

SLIDER
382
448
555
481
x-mean1
x-mean1
-40
40
4.13
1
1
NIL
HORIZONTAL

SLIDER
382
480
555
513
x-mean2
x-mean2
-40
40
-1.24
1
1
NIL
HORIZONTAL

SLIDER
382
512
555
545
x-mean3
x-mean3
-40
40
0.0
1
1
NIL
HORIZONTAL

SLIDER
555
446
728
479
y-mean1
y-mean1
-40
40
3.6
1
1
NIL
HORIZONTAL

SLIDER
554
479
727
512
y-mean2
y-mean2
-40
40
-5.97
1
1
NIL
HORIZONTAL

SLIDER
554
513
727
546
y-mean3
y-mean3
-40
40
0.0
1
1
NIL
HORIZONTAL

SLIDER
727
446
899
479
sd-1
sd-1
0
40
3.43
0.5
1
NIL
HORIZONTAL

SLIDER
728
479
900
512
sd-2
sd-2
0
40
3.69
0.5
1
NIL
HORIZONTAL

SLIDER
726
513
898
546
sd-3
sd-3
0
40
0.0
0.5
1
NIL
HORIZONTAL

TEXTBOX
196
741
708
793
Stickers yellow: Aggregators green; Hunters violet; Predators red; Explorers blue
12
0.0
1

BUTTON
211
560
362
593
Random population
random-pop
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
43
641
262
701
output-directory
C:/Users/jihun/OneDrive/바탕 화면/시뮬레이션 결과
1
0
String

SLIDER
647
11
819
44
valence-lambda
valence-lambda
0
1
0.5
.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="16"/>
    <enumeratedValueSet variable="birth-death-file">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="endogenous-birth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="campaign-ticks">
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="votes1">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="votes2">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="valence-lambda">
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survival-threshold">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fitness-alpha">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misery-alpha">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misery-beta">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output-directory">
      <value value="&quot;C:/Users/jihun/OneDrive/바탕 화면/시뮬레이션 결과&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
