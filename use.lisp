(ql:quickload :web-manager)

(defun test-baidu ()
  (web-manager:add-task (list :id "baidu" :url "https://baidu.com" :attributes "Video" :come-from "test" :description "baidu" :download-type "common" :extractp :zipp t :password " ")))

(defun arrange-s ()
  (web-manager.arrange:arrange (web-manager.head:get-drive-path)))

(defun test-mo () 
  (web-manager:add-task (list :id "mo" :url "file://~/tets-web/Downlaod/" :attributes "Game" :come-from "mcbbs" :description "mcsever" :download-type "local" :extractp :zipp t :password "nil")))

(defun test-bt ()
  (web-manager:add-task (list :id "archlinux"
                              :url "magnet:?xt=urn:btih:287ce5be250c6613ab6021c4a483cbfc672683f8&dn=archlinux-2021.12.01-x86_64.iso"
                              :tag "anime"
                              :description "archlinux"
                              :attributes "video"
                              :download-type "bt"
                              :r18p nil
                              :removep t
                              :password "nil")))
;(web-manager:add-task "baidu" "http://baidu.com")
;(web-manager:get-task-download-info (find-task "baidu") :status)
;(web-manager:add-task (list :id "S1534" :url "local" :attributes "Video" :come-from "LingMeiYushuo" :description "LingMeng2" :download-type "local" :zipp t :password "nil"))
