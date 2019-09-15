(in-package :cl-user)
(ql:quickload "asdf")

(ql:quickload "cl-events") ;load event
(ql:quickload "lparallel") ;load thread pool manager
(ql:quickload "cl-json") ;load json
(ql:quickload "websocket-driver") ;load websocket

;(load "~/Documents/Learn/Lisp/TheWebApp/file-manager/file-manager.lisp")
;(load "~/Documents/Learn/Lisp/TheWebApp/head.lisp")

(load "./web-manager.asd")
(asdf:operate 'asdf:load-op 'web-manager)

(web-manager:add-task (list :id "baidu" :url "https://baidu.com" :attributes "Video" :come-from "test" :description "baidu" :download-type "common"))
;(web-manager:add-task "baidu" "http://baidu.com")
;(web-manager:get-task-download-info (find-task "baidu") :status)

