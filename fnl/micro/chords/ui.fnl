;; UI configuration
(local max-cols 5)
(local cell-width 125)
(local cell-height 20)

(local x-padding 10)
(local y-padding 2)
(local x-margin 30)
(local y-margin 14)

(local key-font-face "Helvetica Bold")
(local name-font-face "Iosevka")
(local font-size 14)
(local key-width 10)
(local text-padding-t 1)
(local key-padding-r 8)

(local screen-offset-y 35)

(local background-color {:red 1 :green 1 :blue 1 :alpha 1})
(local foreground-color {:red 0 :green 0 :blue 0 :alpha 1})
(local shadow-color {:red 0 :green 0 :blue 0 :alpha (/ 1 3)})
(local accent-color {:red 0.388 :green 0.356 :blue 1 :alpha 1})

(local container-border-radius 5)

(local chord-report-offset-y 20)
(local chord-report-x-margin 12)
(local chord-report-height 30)
(local chord-report-text-padding-t 6)
(local chord-report-key-padding-r 6)

(fn cmp-semi-case-insensitive [[a _] [b _]]
    ;; if a and b, when not considering case, are the same...
    (if (= (string.upper a) (string.upper b))
        ;; a is only strictly less than b only when a is lowercase and b is uppercase
        (and (not= a (string.upper a)) (= b (string.upper b)))
    :else
        (< (string.upper a) (string.upper b))))

(lambda build-ui [data chord]
    (local cols (-> (length data) (math.min max-cols)))
    (local rows (-> (length data) (/ max-cols) (math.ceil)))

    (local container-width
        (+ (* cols cell-width) (* (- cols 1) x-padding) (* 2 x-margin)))
    (local container-height
        (+ (* rows cell-height) (* (- rows 1) y-padding) (* 2 y-margin)))

    (local canvas-margin 20)

    (local canvas (hs.canvas.new {
        :w (+ container-width (* 2 canvas-margin))
        :h (+ container-height (* 2 canvas-margin)
                chord-report-height chord-report-offset-y)
    }))

    (local frame (-> (hs.screen.mainScreen) (: :frame)))

    (canvas:topLeft {
        :x (/ (- frame.w container-width (* 2 canvas-margin)) 2)
        :y (- (+ frame.h canvas-margin)
            screen-offset-y
            container-height 
            chord-report-height chord-report-offset-y)
    })

    (canvas:level :overlay)

    (when (> (length chord) 0)
        (local chord-report-width (+
            (* 2 chord-report-x-margin)
            (* (length chord) key-width)
            (* (- (length chord) 1) chord-report-key-padding-r)))

        (local chord-report-x (+
            canvas-margin 
            (/ (- container-width chord-report-width) 2)))
        (local chord-report-y (+ canvas-margin))

        (canvas:insertElement {
            :type :rectangle
            :action :fill
            :roundedRectRadii {
                :xRadius container-border-radius
                :yRadius container-border-radius
            }
            :fillColor background-color
            :frame {
                :x chord-report-x
                :y chord-report-y
                :h chord-report-height
                :w chord-report-width
            }
            :withShadow true
            :shadow {
                :blurRadius 10.0
                :color shadow-color
                :offset {:h -2 :w 1}
            }
        })

        (each [n key (ipairs chord)]
            (local c (- n 1))
            (canvas:insertElement {
                :type :text
                :action :fill
                :frame {
                    :x (+ chord-report-x chord-report-x-margin (* c key-width) (* c chord-report-key-padding-r ))
                    :y (+ chord-report-y chord-report-text-padding-t)
                    :w key-width
                    :h chord-report-height
                }
                :text (hs.styledtext.new key {
                    :font {:name name-font-face :size font-size }
                    :color foreground-color
                    :underlineStyle (if (= key (string.upper key)) 1 0)
                    :baselineOffset (if (= key (string.upper key)) 2 0)
                    :paragraphStyle { :alignment :center }
                })
            })))

    (canvas:insertElement {
        :type :rectangle
        :action :fill
        :roundedRectRadii {
            :xRadius container-border-radius
            :yRadius container-border-radius
        }
        :fillColor background-color
        :frame {
            :x canvas-margin
            :y (+ canvas-margin chord-report-height chord-report-offset-y)
            :h container-height
            :w container-width
        }
        :withShadow true
        :shadow {
            :blurRadius 10.0
            :color shadow-color
            :offset {:h -2 :w 1}
        }
    })

    (table.sort data cmp-semi-case-insensitive)

    (each [n entry (ipairs data)]
        (local key (. entry 1))
        (local name (. entry 2))
        (local opts (if (= 4 (length entry)) (. entry 3) {}))
        (local display-key (or opts.display key))

        (local c (-> n (- 1) (/ max-cols) (math.floor)))
        (local r (-> n (- 1) (% max-cols)))

        (local cell-x
            (+ canvas-margin x-margin (* r cell-width) (* r x-padding)))
        (local cell-y
            (+ canvas-margin chord-report-height chord-report-offset-y
                y-margin (* c cell-height) (* c y-padding)))

        (canvas:insertElement {
            :type :text
            :action :fill
            :frame {
                :x cell-x
                :y (+ cell-y text-padding-t -1)
                :w key-width
                :h cell-height
            }
            :text (hs.styledtext.new display-key {
                :font {:name (.. name-font-face " Bold") :size (+ 2 font-size) }
                :color accent-color
                :underlineStyle (if (= key (string.upper key)) 2 0)
                :baselineOffset (if (= key (string.upper key)) 3 0)
            })
        })

        (canvas:insertElement {
            :type :text
            :text name
            :action :fill
            :frame {
                :x (+ cell-x key-width key-padding-r)
                :y (+ cell-y text-padding-t)
                :w (- cell-width key-width key-padding-r)
                :h cell-height
            }
            :textAlignment :left
            :textColor foreground-color
            :textFont name-font-face
            :textSize font-size
        }))

    canvas)

(lambda make-chorder-ui []
    (var canvas nil)

    (lambda on-event [event]
        (match event
            [:update data chord] (do
                (when canvas
                    (canvas:hide 0))
                (set canvas (build-ui data chord))
                (canvas:show (if canvas 0 0.15)))
        
            [:done status]
            (when canvas
                (canvas:hide 0.15)
                (set canvas nil))))
        
    { : on-event })

{
    : make-chorder-ui
}