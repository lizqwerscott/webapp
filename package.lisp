;;;;The package web-manager
;;;Load Pakage
(in-package :cl-user)

(defpackage :web-manager.head
  (:use :common-lisp :uiop)
  (:export :run-shell
           :get-directory
           :unrar-file
           :unzip-file
           :un7z-file
           :extract
           :zip-file
           :move-file
           :move-files
           :move-dir
           :move-dirs
           :move-file-or-dir
           :move-files-or-dirs
           :get-drive-path
           :find-compressed))

(defpackage :web-manager.arrange
  (:use :common-lisp :web-manager.head)
  (:export :arrange))

(defpackage :web-manager.file
  (:use :common-lisp :uiop :web-manager.head :web-manager.arrange)
  (:export :add-table
           :remove-table
           :search-table
           :show-table))

(defpackage :web-manager.download
  (:use :common-lisp :uiop :web-manager.head)
  (:export :download))

(defpackage :web-manager.handle
  (:use :common-lisp :web-manager.head)
  (:export :handle))

(defpackage :web-manager
  (:use :common-lisp :web-manager.head :web-manager.download :web-manager.file :web-manager.handle :bordeaux-threads :web-manager.arrange)
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
           :update-task))

