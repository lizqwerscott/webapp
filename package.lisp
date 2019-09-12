;;;;The package web-manager
;;;Load Pakage
(in-package :cl-user)

;(ql:quickload "cl-events") ;load event
;(ql:quickload "lparallel") ;load thread pool manager
;(ql:quickload "cl-json") ;load json
;(ql:quickload "websocket-driver") ;load websocket

(defpackage :web-manager.head
  (:use :common-lisp)
  (:export :run-shell))

(defpackage :web-manager.download
  (:use :common-lisp :web-manager.head)
  (:export :download))

(defpackage :web-manager.file
  (:use :common-lisp :cl-events :web-manager.head)
  (:export :add-table
           :remove-table
           :search-table))

(defpackage :web-manager
  (:use :common-lisp :web-manager.head :web-manager.download :web-manager.file :cl-events :lparallel :bordeaux-threads)
  (:export :add-task
           :remove-task
           :task
           :start-task
           :pause-task
           :unpause-task
           :get-task-download-info
           :show-task
           :show-list
           :find-task
           :run-manager))

