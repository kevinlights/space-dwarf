(local colour (require :lib.colour))

{:colours {:sky (colour.hex-to-rgba "#c5ccb8")
           :ui-back (colour.hex-to-rgba "#6f6776")
           :ui-back-2 (colour.hex-to-rgba "#919197")
           :ui-text (colour.hex-to-rgba "#433455")
           :sky-text (colour.hex-to-rgba "#666092")
           :blue   (colour.hex-to-rgba "#0188a5")
           :black  (colour.hex-to-rgba "#222034")
           :red    (colour.hex-to-rgba "#df0772")
           :grey   (colour.hex-to-rgba "#595652")
           :blue-grey   (colour.hex-to-rgba "#9babb7")
           :white  (colour.hex-to-rgba "#ffffff")
           :pink  (colour.hex-to-rgba "#d77bba")
           :background  (colour.hex-to-rgba "#372134")
           :light-yellow  (colour.hex-to-rgba "#cbdbfc")
           :text  (colour.hex-to-rgba "#222034")
           }
 :screen-width 1200
 :screen-height 660
 :w2 600
 :h2 330
 :keys {:left ["left" "a"]
        :right ["right" "d"]
        :up ["up" "w"]
        :down ["down" "s"]
        :interact ["space" "return"]
        :back ["escape"]
        :destroy ["backspace" "delete"]}
 :player-speed {
                :walk {:rate 10
                       :decay 20
                       :max 1
                       :max-s2 (/ 1 (math.sqrt 2))
                       :floor 0.1}
                }
 }
