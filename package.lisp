;;;;The package web-manager
;;;Load Pakage
(in-package :cl-user)

(ql:quickload "cl-events") ;load event
(ql:quickload "lparallel") ;load thread pool manager
(ql:quickload "cl-json") ;load json
(ql:quickload "websocket-driver") ;load websocket

(defpackage "aria2-manager"
  (:use :common-lisp :cl-events :cl-json :websocket-driver)
  (:export :update-download
           :get-download-info
           :remove-download
           :pause-download
           :unpause-download
           :get-status
           :download-object))

(defpackage "web-manager"
  (:use :common-lisp :aria2-manager :cl-events :lparallel)
  (:export :add-task
           :remove-task
           :task
           :start-task
           :pause-task
           :unpause-task
           :get-task-download-info
           :show-task
           :show-list
           :run-manager))
