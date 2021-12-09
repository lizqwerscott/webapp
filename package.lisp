;;;;The package web-manager
;;;Load Pakage
(in-package :cl-user)

(defpackage :web-manager.head
  (:use :common-lisp :uiop)
  (:export :run-shell
           :last1
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
           :set-run-module
           :find-compressed
           :directory-e
           :make-next-dir
           :get-parents-dir
           :directoryp
           :empty-dirp
           :prompt-read
           :prompt-read-number
           :prompt-switch
           :want-to-self-input))
(defpackage :web-manager.arrange
  (:use :common-lisp :web-manager.head)
  (:export :arrange))

(defpackage :web-manager.file
  (:use :common-lisp :uiop :web-manager.head :web-manager.arrange)
  (:export :table
           :delete-ben
           :check-table
           :archivep-table
           :benp-table
           :zip-table
           :extract-table
           :add-table
           :remove-table
           :search-table
           :show-table
           :check-all-table 
           :load-table-manager))

(defpackage :web-manager.download
  (:use :common-lisp :uiop :web-manager.head)
  (:export :download))

(defpackage :web-manager.handle
  (:use :common-lisp :web-manager.head)
  (:export :handle))

(defpackage :web-manager
  (:use :common-lisp :web-manager.head :web-manager.download :web-manager.file :web-manager.handle :bordeaux-threads :web-manager.arrange)
  (:export :add-task
           :prompt-for-task-list
           :pfts
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

