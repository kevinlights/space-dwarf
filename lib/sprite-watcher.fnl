(local timer {})

(fn timer.update [self dt]
  (if self.active
      (do
          (set self.time (+ self.time dt))
        (> self.time self.end))
      false))

(fn timer.reset [self]
  (set self.time 0))

(local timer-mt {:__index timer})

(fn new-timer [end]
  (setmetatable
   {:time 0
    :end end
    :active true}
   timer-mt))

(local sprite-watcher {})

(fn default-callback [changed-files]
  (local cargo (require :lib.cargo))
  (each [_ file (ipairs changed-files)]
    (tset assets :sprites (cargo.init "assets/sprites"))))

(fn sprite-watcher.init [period? callback? directory?]
  (local directory (or directory? "/assets/sprites/"))
  (local files (love.filesystem.getDirectoryItems directory))
  (local ret {:sprites {}
              :directory directory
              :files files
              :callback (or callback? default-callback)
              :timer (timer (or period? 1))})
  (each [_ file (ipairs files)]
    (tset ret.sprites file (love.filesystem.getInfo (.. directory  file))))
  ret)

(fn sprite-watcher.changes [self]
  (local files (love.filesystem.getDirectoryItems self.directory))
  (tset self :files files)
  (var changes false)
  (local changed-files [])
  (each [_ file (ipairs files)]
    (let [file-info (love.filesystem.getInfo (.. self.directory  file))]
      (when (~= file-info.modtime (. (. self.sprites file) :modtime))
        (set changes true)
        (table.insert changed-files file)
        (tset self.sprites file file-info))))
  (values changes changed-files))

(fn sprite-watcher.update [self dt]
  (if (self.timer:update dt)
      (do
        (let [(change changed-files) (self:changes)]
          (when change
            (self.callback changed-files)))
        (self.timer:reset)
        changed-files)
      []
      ))

(fn sprite-watcher.print [self]
  (pp self.sprites))

(local sprite-watcher-mt
       {:__index sprite-watcher
        :print sprite-watcher.print
        :update sprite-watcher.update
        :changes sprite-watcher.changes})

(fn []
  (setmetatable (sprite-watcher.init) sprite-watcher-mt))
