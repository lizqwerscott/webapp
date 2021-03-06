(in-package :cl-user)
#+clozure 
(load "/home/pi/quicklisp/setup.lisp")
#+sbcl
(ql:quickload "asdf")

(ql:quickload "bordeaux-threads")
(ql:quickload "cl-strings")
;(ql:quickload "cl-events") ;load event
;(ql:quickload "lparallel") ;load thread pool manager
;(ql:quickload "cl-json") ;load json
;(ql:quickload "websocket-driver") ;load websocket
(asdf:load-system :uiop)

;(load "~/Documents/Learn/Lisp/TheWebApp/file-manager/file-manager.lisp")
;(load "~/Documents/Learn/Lisp/TheWebApp/head.lisp")

(load "./web-manager.asd")
(asdf:operate 'asdf:load-op 'web-manager)

(defun test-baidu ()
  (web-manager:add-task (list :id "baidu" :url "https://baidu.com" :attributes "Video" :come-from "test" :description "baidu" :download-type "common" :extractp :zipp t :password " ")))

(defun arrange-s ()
  (web-manager.arrange:arrange (web-manager.head:get-drive-path)))

(defun test-mo () 
  (web-manager:add-task (list :id "mo" :url "file://~/tets-web/Downlaod/" :attributes "Game" :come-from "mcbbs" :description "mcsever" :download-type "local" :extractp :zipp t :password "nil")))
;(web-manager:add-task "baidu" "http://baidu.com")
;(web-manager:get-task-download-info (find-task "baidu") :status)
;(web-manager:add-task (list :id "S1534" :url "local" :attributes "Video" :come-from "LingMeiYushuo" :description "LingMeng2" :download-type "local" :zipp t :password "nil"))
