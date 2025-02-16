(local notify {
	:send (fn [title text]
		(-> (hs.notify.new { :title title :informativeText text })
		(: :send)))
})

(lambda make-watcher [path]
	(lambda on-reload [paths]
		(var changed false)
		(each [i path (ipairs paths)]
			(set changed (or changed (not (string.find path ".git")))))
		(when changed
			(hs.reload)
			(hs.notify.withdrawAll)
			(notify.send "Config watcher" "Reloading configuration")))
	
	(var hs-watcher (hs.pathwatcher.new path on-reload))

	(lambda start []
		(hs-watcher:start))

	{ : start })

{ : make-watcher }
