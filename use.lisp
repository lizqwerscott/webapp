(ql:quickload "asdf")

(ql:quickload "cl-events") ;load event
(ql:quickload "lparallel") ;load thread pool manager
(ql:quickload "cl-json") ;load json
(ql:quickload "websocket-driver") ;load websocket

(load "./web-manager.asd")
(asdf:operate 'asdf:load-op 'web-manager)

(web-manager:add-task "baidu" "http://baidu.com")
(web-manager:get-task-download-info (find-task "baidu") :status)

