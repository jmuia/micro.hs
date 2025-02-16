(local key-events [
    hs.eventtap.event.types.keyDown
    hs.eventtap.event.types.keyUp
])

(lambda parse-line [line]
    (if (= 4 (length line))
        line
    :else
        [(. line 1) (. line 2) {} (. line 3)]))

;; This class is responsible for taking over the keyboard and listening
;; to key events to advance through the chords defined by the chord-tree
;; passed to start. 
;;
;; The lifecycle of this class is intended to be one invocation of the
;; chorder.
;;
(lambda make-chorder [chord-tree ?subscriber]

    (local subscriber ?subscriber)

    (var key-set chord-tree)
    (var chord [])
    (var state :init)
    (var exit-status nil)

    ;; If a node in the tree is configured to as a hydra, then Chorder will
    ;; return to that node when a leaf node is successfully reached (but not
    ;; if ESC is hit, or an invalid key is hit).
    (var hydra nil)
    (var hydra-chord nil)

    (var tap nil)

    (lambda emit-update []
        (when subscriber
            (subscriber [:update key-set chord])))

    (lambda emit-done [status]
        (when subscriber
            (subscriber [:done status])))

    (lambda stop [status]
        (set exit-status status)
        (set state :exiting))

    (lambda exit []
        (emit-done exit-status)
        ;; Shut down the event tap.
        (tap:stop))

    (lambda execute [line]
        (local [_ description opts action-or-set] (parse-line line))

        (case (type action-or-set)

            ;; If key leads to another set, step into it.
            :table (do
                (when opts.hydra
                    (set hydra action-or-set)
                    (set hydra-chord [(table.unpack chord)]))
                (set key-set action-or-set)
                (emit-update))

            ;; If the key leads to an action, exit and execute it.
            :function (do
                (if hydra (do
                    (set key-set hydra)
                    (set chord [(table.unpack hydra-chord)])
                    (emit-update)
                ) :else
                    (stop :complete))
                (action-or-set))))

    (lambda on-keypress [event]
        ;; Ignore repeats.
        (local is-repeat (event:getProperty hs.eventtap.event.properties.keyboardEventAutorepeat))
        (when (not= is-repeat 0)
            (lua "return true"))

        (local key-code (event:getKeyCode))
        (local event-type (event:getType))

        ;; If the very first (non-repeat) key event is a keyUp event, then it
        ;; is the hotkey used to activate chord capture. We don't want to consider
        ;; that keypress to be part of the chord. However, we do need to let the
        ;; event continue being processed by the OS, otherwise the OS won't realize
        ;; that the hotkey was ever released (unitl the key is pressed again outside
        ;; of the eventtap).
        (when (= state :init)
            (set state :running)
            (when (= hs.eventtap.event.types.keyUp event-type)
                (lua "return false")))
    
        ;; Ignore keyUp events during normal operation.
        (when (= state :running)
            (when (= hs.eventtap.event.types.keyUp event-type)
                (lua "return true")))

        ;; Wait to exit until get a keyUp event so that the last key pressed
        ;; when forming a chord doesn't escape the context of the chord.
        (when (= state :exiting)
            (when (= hs.eventtap.event.types.keyUp event-type)
                (exit))
            (lua "return true"))

        ;; Always exit on ESC.
        (when (= key-code 53)
            (stop :escape)
            (lua "return true"))

        ;; Add the character to the chord.
        (local char (event:getCharacters true))
        (table.insert chord char)

        ;; Try to find an entry in the current set for the pressed character.
        (local line (hs.fnutils.find key-set (fn [line] (= char (. line 1)))))

        ;; Exit if key isn't in set.
        (when (not line)
            (stop :invalid)
            (lua "return true"))

        (execute line)

        ;; Eat the keypress.
        true)

    (set tap (hs.eventtap.new key-events on-keypress))

    (tap:start)

    (emit-update)

    {})

{ : make-chorder }
